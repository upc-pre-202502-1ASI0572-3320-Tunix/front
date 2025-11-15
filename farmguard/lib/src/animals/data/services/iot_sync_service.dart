import 'dart:async';
import '../../domain/entities/iot_data.dart';
import '../datasources/iot_remote_data_source.dart';

/// Servicio que gestiona la sincronización periódica de datos IoT
class IotSyncService {
  final IotRemoteDataSource remoteDataSource;
  
  List<IotData> _cachedData = [];
  int _currentIndex = 0;
  Timer? _rotationTimer;
  StreamController<IotData>? _dataStreamController;

  IotSyncService({required this.remoteDataSource});

  /// Stream que emite datos actualizados cada 15 segundos
  Stream<IotData> get dataStream {
    _dataStreamController ??= StreamController<IotData>.broadcast();
    return _dataStreamController!.stream;
  }

  /// Inicia la sincronización con la URL IoT
  Future<void> startSync(String iotUrl) async {
    // Cancelar sincronización previa si existe
    stopSync();

    try {
      // Obtener datos iniciales
      _cachedData = await remoteDataSource.getIotData(iotUrl);
      
      if (_cachedData.isEmpty) {
        throw Exception('No hay datos disponibles desde la URL IoT');
      }

      // Emitir primer dato
      _currentIndex = 0;
      _emitCurrentData();

      // Iniciar rotación cada 5 segundos
      _rotationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _rotateAndEmit();
      });
    } catch (e) {
      throw Exception('Error al iniciar sincronización IoT: $e');
    }
  }

  /// Detiene la sincronización
  void stopSync() {
    _rotationTimer?.cancel();
    _rotationTimer = null;
    _currentIndex = 0;
  }

  /// Rota al siguiente registro y lo emite
  void _rotateAndEmit() {
    if (_cachedData.isEmpty) return;
    
    _currentIndex = (_currentIndex + 1) % _cachedData.length;
    _emitCurrentData();
  }

  /// Emite el dato actual al stream
  void _emitCurrentData() {
    if (_cachedData.isNotEmpty && _dataStreamController != null) {
      _dataStreamController!.add(_cachedData[_currentIndex]);
    }
  }

  /// Obtiene el dato actual sin esperar el stream
  IotData? get currentData {
    if (_cachedData.isEmpty) return null;
    return _cachedData[_currentIndex];
  }

  /// Limpia recursos
  void dispose() {
    stopSync();
    _dataStreamController?.close();
    _dataStreamController = null;
    _cachedData.clear();
  }
}
