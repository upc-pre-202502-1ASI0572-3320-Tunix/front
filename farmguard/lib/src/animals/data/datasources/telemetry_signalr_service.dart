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
  Map<String, HubConnection> _hubConnections = {}; // Múltiples conexiones por filtro
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  
  // Stream público para que otros componentes se suscriban
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  
  bool get isConnected => _hubConnections.values.any((conn) => conn.state == HubConnectionState.Connected);

  Future<void> connect({String filter = 'collar'}) async {
    try {
      // Limpiar el filtro: si es una lista separada por comas, mantenerla
      // Si contiene URLs o datos inválidos, filtrar solo los valores válidos (sin /)
      final filters = filter
          .split(',')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty && !f.contains('/')) // Rechazar URLs y valores vacíos
          .toList();
      
      final finalFilters = filters.isNotEmpty ? filters : ['collar'];

      print('[SignalR] 🔗 Conectando a ${finalFilters.length} filtro(s): $finalFilters');
      
      // Crear una conexión para cada filtro
      for (final singleFilter in finalFilters) {
        if (_hubConnections.containsKey(singleFilter) && 
            _hubConnections[singleFilter]!.state == HubConnectionState.Connected) {
          print('[SignalR] ✅ Ya conectado a "$singleFilter", saltando...');
          continue;
        }

        print('[SignalR] 🔗 Conectando a filtro: "$singleFilter"');
        await _connectToFilter(singleFilter);
      }
    } catch (e) {
      print('[SignalR ERROR] Failed to connect: $e');
    }
  }

  Future<void> _connectToFilter(String filter) async {
    try {
      // URL completa sin /api/ ya que SignalR usa su propia ruta
      final hubUrl = 'https://www.ibrayan.dev/hubs/telemetry?filtro=$filter';

      // Obtener token de autenticación si existe
      final token = await TokenStorage.getToken();
      
      // Configurar conexión SignalR para este filtro
      final hubConnection = HubConnectionBuilder()
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
      hubConnection.onclose(({error}) => print('[SignalR] Conexión cerrada ($filter): $error'));
      hubConnection.onreconnecting(({error}) => print('[SignalR] Reconectando ($filter)...'));
      hubConnection.onreconnected(({connectionId}) => print('[SignalR] Reconectado ($filter)'));

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
        hubConnection.on(name, (arguments) => _handleTelemetryData(arguments, filter));
      }

      // Iniciar conexión
      print('[SignalR] Intentando conectar a $hubUrl');
      await hubConnection.start();
      
      // Almacenar la conexión
      _hubConnections[filter] = hubConnection;
      
      print('[SignalR] ✅ Conectado exitosamente a "$filter"');
      print('[SignalR] Estado: ${hubConnection.state}');
      print('[SignalR] Connection ID: ${hubConnection.connectionId}');
      
    } catch (e) {
      print('[SignalR ERROR] Failed to connect to "$filter": $e');
    }
  }

  void _handleTelemetryData(List<Object?>? arguments, String filter) {
    try {
      print('[SignalR] === HANDLER INVOCADO (filtro: $filter) ===');
      if (arguments == null || arguments.isEmpty) {
        print('[SignalR] Arguments es null o vacío');
        return;
      }

      print("[SignalR] Número de argumentos: ${arguments.length}");
      print("[SignalR] Data cruda recibida: $arguments");
      print("[SignalR] Tipo de datos: ${arguments.map((a) => a.runtimeType).toList()}");

      var rawData = arguments[0];
      print("[SignalR] Raw data type: ${rawData.runtimeType}");
      
      Map<String, dynamic>? jsonData;

      // CASO 1: La data llega como un String JSON (común en algunas configuraciones de SignalR)
      if (rawData is String) {
        print('[SignalR] Raw data es String, decodificando...');
        try {
          jsonData = jsonDecode(rawData);
          print('[SignalR] JSON decodificado: $jsonData');
        } catch (e) {
          print("[SignalR] Error decodificando string JSON: $e");
        }
      } 
      // CASO 2: La data llega ya como Objeto/Mapa
      else if (rawData is Map) {
        print('[SignalR] Raw data es Map, usando directamente...');
        jsonData = Map<String, dynamic>.from(rawData);
        print('[SignalR] Map convertido: $jsonData');
      } else {
        print('[SignalR] Raw data no es String ni Map, es: ${rawData.runtimeType}');
      }

      if (jsonData != null) {
        print('[SignalR] JSON data no es null, procesando...');
        // Verificar si el JSON tiene una propiedad raíz que envuelve la data (unwrap)
        // Ejemplo: { "telemetry": { "temp": 30... } }
        if (jsonData.keys.length == 1 && jsonData.values.first is Map) {
          print("[SignalR] Desempaquetando objeto anidado...");
          jsonData = Map<String, dynamic>.from(jsonData.values.first as Map);
        }

        final telemetry = TelemetryData.fromJson(jsonData);
        print("[SignalR] ✅ Procesado con éxito: $telemetry");
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
      print('[SignalR] Desconectando ${_hubConnections.length} conexión(es)...');
      for (final entry in _hubConnections.entries) {
        await entry.value.stop();
        print('[SignalR] ✅ Desconectado: ${entry.key}');
      }
      _hubConnections.clear();
    } catch (e) {
      print('[SignalR] Error al desconectar: $e');
    }
  }

  void dispose() {
    disconnect();
    _telemetryController.close();
  }
}
