class AppConfig {
  // Configuración de API
  static String get apiBaseUrl {
    // Usar siempre la URL directa para desarrollo
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://www.ibrayan.dev/api',
    );
    
    // NOTA: Para producción web con proxy reverso, cambiar a:
    // if (kIsWeb && isProduction) {
    //   return '/api';
    // } else {
    //   return const String.fromEnvironment(...);
    // }
  }

  static const String apiVersion = '/v1';

  // Entorno actual
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // URL base completa
  static String get baseUrl => '$apiBaseUrl$apiVersion';
}
