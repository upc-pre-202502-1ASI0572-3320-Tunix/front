import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformConfig {
  // Verificar plataforma
  static bool get isWeb => kIsWeb;
  static bool get isMobile => !kIsWeb;

  // Timeout según plataforma
  static Duration get connectTimeout {
    return isWeb
        ? const Duration(seconds: 60) // Web puede ser más lento
        : const Duration(seconds: 30);
  }

  static Duration get receiveTimeout {
    return isWeb
        ? const Duration(seconds: 60)
        : const Duration(seconds: 30);
  }

  // Características disponibles por plataforma
  static bool get useSecureStorage => !isWeb;
  static bool get canUseBiometrics => !isWeb;
  static bool get canUseCamera => !isWeb;
  static bool get canUsePushNotifications => !isWeb;
}
