import 'dart:async';
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
    return TelemetryData(
      deviceId: json['device_id'] as String,
      bpm: json['bpm'] as int,
      temperature: (json['temperature'] as num).toDouble(),
      location: json['location'] as String,
    );
  }

  @override
  String toString() {
    return 'TelemetryData(deviceId: $deviceId, bpm: $bpm, temp: $temperature, location: $location)';
  }
}

class TelemetrySignalRService {
  HubConnection? _hubConnection;
  final _telemetryController = StreamController<TelemetryData>.broadcast();
  
  // Stream público para que otros componentes se suscriban
  Stream<TelemetryData> get telemetryStream => _telemetryController.stream;
  
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  Future<void> connect({String filter = 'collar'}) async {
    if (_hubConnection != null && isConnected) {
      print('[SIGNALR] Already connected');
      return;
    }

    try {
      // URL completa sin /api/ ya que SignalR usa su propia ruta
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
      _hubConnection!.onclose(({error}) {});
      _hubConnection!.onreconnecting(({error}) {});
      _hubConnection!.onreconnected(({connectionId}) {});

      // Registrar listener para recibir datos de telemetría
      // Probar múltiples nombres de método que el servidor puede usar
      _hubConnection!.on('ReceiveTelemetry', _handleTelemetryData);
      _hubConnection!.on('TelemetryUpdate', _handleTelemetryData);
      _hubConnection!.on('telemetry', _handleTelemetryData);
      _hubConnection!.on('SendTelemetry', _handleTelemetryData);
      _hubConnection!.on('UpdateTelemetry', _handleTelemetryData);
      _hubConnection!.on('NewTelemetry', _handleTelemetryData);

      // Iniciar conexión
      await _hubConnection!.start();
      
    } catch (e) {
      print('[SIGNALR ERROR] Failed to connect: $e');
      rethrow;
    }
  }

  void _handleTelemetryData(List<Object?>? arguments) {
    try {
      if (arguments == null || arguments.isEmpty) {
        return;
      }

      // El servidor puede enviar el objeto directamente o como primer argumento
      final data = arguments[0];
      
      Map<String, dynamic>? jsonData;
      
      // Intentar diferentes formatos
      if (data is Map<String, dynamic>) {
        jsonData = data;
      } else if (data is Map) {
        // Convertir Map genérico a Map<String, dynamic>
        jsonData = Map<String, dynamic>.from(data);
      }
      
      if (jsonData != null) {
        final telemetry = TelemetryData.fromJson(jsonData);
        _telemetryController.add(telemetry);
      }
    } catch (e) {
    }
  }

  Future<void> disconnect() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection!.stop();
        _hubConnection = null;
      }
    } catch (e) {
    }
  }

  void dispose() {
    disconnect();
    _telemetryController.close();
  }
}
