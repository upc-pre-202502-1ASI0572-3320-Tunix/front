import 'dart:async';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import '../../../../core/storage/token_storage.dart';

class TelemetryData {
  final String deviceId;
  final int bpm;
  final double temperature;
  final String location;

  TelemetryData({
    required this.deviceId,
    required this.bpm,
    required this.temperature,
    required this.location,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    // 1. Normalizar claves: Convertimos todas las claves del JSON a minúsculas
    // para no preocuparnos si viene "DeviceId" o "device_id"
    final Map<String, dynamic> data = {};
    json.forEach((key, value) {
      data[key.toLowerCase()] = value;
    });

    // 2. Función auxiliar para buscar múltiples variantes de una clave
    dynamic getVal(List<String> keys) {
      for (final key in keys) {
        if (data.containsKey(key) && data[key] != null) {
          return data[key];
        }
      }
      return null;
    }

    // 3. Extraer valores usando la misma lógica defensiva que el código Vue
    return TelemetryData(
      // Busca: device_id, deviceid, device, sensorid, sensor
      deviceId: (getVal(['device_id', 'deviceid', 'device', 'sensorid', 'sensor', 'sensor_id']) ?? 'unknown').toString(),
      
      // Busca: bpm, heartrate, hr, heart_rate
      bpm: int.tryParse(getVal(['bpm', 'heartrate', 'hr', 'heart_rate']).toString()) ?? 0,
      
      // Busca: temperature, temp, t
      temperature: double.tryParse(getVal(['temperature', 'temp', 't']).toString()) ?? 0.0,
      
      // Busca: location, loc
      location: (getVal(['location', 'loc']) ?? 'Unknown').toString(),
    );
  }

  @override
  String toString() => 'Telemetry: $deviceId | Temp: $temperature | BPM: $bpm';
}

class TelemetrySignalRService {
  HubConnection? _hubConnection;
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  
  // Stream público para que otros componentes se suscriban
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  Future<void> connect({String filter = 'collar'}) async {
    if (_hubConnection != null && isConnected) {
      return;
    }

    try {
      // URL completa sin /api/ ya que SignalR usa su propia ruta
      // Nota: Asegúrate que esta URL sea accesible desde el dispositivo/emulador
      final hubUrl = 'https://www.ibrayan.dev/hubs/telemetry?filtro=$filter';

      // Obtener token de autenticación si existe
      final token = await TokenStorage.getToken();
      
      // Configurar conexión SignalR
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => token ?? '',
              // Configurar transporte (WebSockets preferido)
              transport: HttpTransportType.WebSockets,
            ),
          )
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
          .build();

      // Registrar handlers de eventos de conexión
      _hubConnection!.onclose(({error}) => print('[SignalR] Conexión cerrada: $error'));
      _hubConnection!.onreconnecting(({error}) => print('[SignalR] Reconectando...'));
      _hubConnection!.onreconnected(({connectionId}) => print('[SignalR] Reconectado'));

      // Registrar handlers para múltiples nombres de eventos
      // Esto cubre todas las posibilidades que vimos en el código de Vue
      final eventNames = [
        'ReceiveTelemetry',
        'Telemetry',            // Común en SignalR
        'BroadcastTelemetry',   // Común para broadcast
        'telemetry',
        'SendTelemetry',
        'UpdateTelemetry',
        'NewTelemetry'
      ];

      for (var name in eventNames) {
        _hubConnection!.on(name, _handleTelemetryData);
      }

      // Iniciar conexión
      print('[SignalR] Intentando conectar a $hubUrl');
      await _hubConnection!.start();
      print('[SignalR] Conectado exitosamente');
      
    } catch (e) {
      print('[SignalR ERROR] Failed to connect: $e');
      // No relanzamos para no romper la app si falla la telemetría, 
      // pero podrías hacerlo si es crítica.
    }
  }

  void _handleTelemetryData(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) return;

      print("[SignalR] Data cruda recibida: $arguments");

      var rawData = arguments[0];
      Map<String, dynamic>? jsonData;

      // CASO 1: La data llega como un String JSON (común en algunas configuraciones de SignalR)
      if (rawData is String) {
        try {
          jsonData = jsonDecode(rawData);
        } catch (e) {
          print("[SignalR] Error decodificando string JSON: $e");
        }
      } 
      // CASO 2: La data llega ya como Objeto/Mapa
      else if (rawData is Map) {
        jsonData = Map<String, dynamic>.from(rawData);
      }

      if (jsonData != null) {
        // Verificar si el JSON tiene una propiedad raíz que envuelve la data (unwrap)
        // Ejemplo: { "telemetry": { "temp": 30... } }
        if (jsonData.keys.length == 1 && jsonData.values.first is Map) {
          print("[SignalR] Desempaquetando objeto anidado...");
          jsonData = Map<String, dynamic>.from(jsonData.values.first as Map);
        }

        final telemetry = TelemetryData.fromJson(jsonData);
        print("[SignalR] Procesado con éxito: $telemetry");
        _telemetryController.add(telemetry);
      } else {
        print("[SignalR] No se pudo interpretar la data como Mapa ni como String JSON");
      }
    } catch (e, stack) {
      // IMPORTANTE: Imprimir el error para que no sea silencioso
      print("[SignalR Error] Parsing failed: $e");
      print(stack);
    }
  }

  Future<void> disconnect() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection!.stop();
        _hubConnection = null;
      }
    } catch (e) {
      print('[SignalR] Error al desconectar: $e');
    }
  }

  void dispose() {
    disconnect();
    _telemetryController.close();
  }
}