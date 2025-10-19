import 'package:flutter/foundation.dart' show kIsWeb;

/// Clase para verificar conectividad
/// En producción, puedes agregar paquetes como connectivity_plus
class NetworkInfo {
  Future<bool> get isConnected async {
    if (kIsWeb) {
      // En web, asumimos que hay conexión
      // Puedes mejorar esto con window.navigator.onLine
      return true;
    }

    // En mobile, puedes usar connectivity_plus
    // Por ahora, asumimos que hay conexión
    // TODO: Implementar verificación real de red
    return true;
  }
}
