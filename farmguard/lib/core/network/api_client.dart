import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../config/platform_config.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio _dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: PlatformConfig.connectTimeout,
        receiveTimeout: PlatformConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autorización
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Log en desarrollo (deshabilitado)
          // if (AppConfig.isDevelopment) {
          //   print('🌐 REQUEST[${options.method}] => ${options.uri}');
          //   print('Headers: ${options.headers}');
          //   if (options.data != null) {
          //     print('Body: ${options.data}');
          //   }
          // }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log en desarrollo (deshabilitado)
          // if (AppConfig.isDevelopment) {
          //   print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
          //   print('Data: ${response.data}');
          // }
          return handler.next(response);
        },
        onError: (error, handler) async {
          // Log en desarrollo (deshabilitado)
          // if (AppConfig.isDevelopment) {
          //   print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
          //   print('Message: ${error.message}');
          //   print('Data: ${error.response?.data}');
          // }

          // Manejo de token expirado
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Reintentar la petición original
              return handler.resolve(await _retry(error.requestOptions));
            } else {
              // Token refresh falló, limpiar tokens
              await TokenStorage.clearTokens();
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];

        await TokenStorage.saveToken(newToken);
        await TokenStorage.saveRefreshToken(newRefreshToken);

        return true;
      }
      return false;
    } catch (e) {
      // Error refreshing token (log deshabilitado)
      // print('Error refreshing token: $e');
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await TokenStorage.getToken();
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Getter para acceder al cliente Dio
  Dio get dio => _dio;

  // Métodos helper para peticiones comunes
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
