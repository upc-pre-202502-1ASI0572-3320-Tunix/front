import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/config/app_config.dart';
import '../models/sign_in_request.dart';
import '../models/sign_in_response.dart';
import '../models/sign_up_request.dart';
import '../models/sign_up_response.dart';

/// DataSource remoto para Auth
/// Maneja las llamadas a la API
abstract class AuthRemoteDataSource {
  Future<SignInResponse> signIn(SignInRequest request);
  Future<SignUpResponse> signUp(SignUpRequest request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SignInResponse> signIn(SignInRequest request) async {
    try {
      final response = await apiClient.post(
        ApiConstants.signIn,
        data: request.toJson(),
      );

      return SignInResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      // Usar http package para multipart
      final uri = Uri.parse('${AppConfig.baseUrl}${ApiConstants.signUp}');
      final httpRequest = http.MultipartRequest('POST', uri);

      // Agregar campos de texto
      httpRequest.fields['username'] = request.username;
      httpRequest.fields['password'] = request.password;
      httpRequest.fields['firstName'] = request.firstName;
      httpRequest.fields['lastName'] = request.lastName;
      httpRequest.fields['email'] = request.email;

      // Agregar imagen si existe
      if (request.photoBytes != null && request.photoFileName != null) {
        httpRequest.files.add(
          http.MultipartFile.fromBytes(
            'urlPhoto', // El nombre del campo según el backend
            request.photoBytes!,
            filename: request.photoFileName,
          ),
        );
      }

      // Enviar request
      final streamedResponse = await httpRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Backend devuelve: { "message": "User created successfully" }
        return SignUpResponse(message: 'Usuario creado exitosamente');
      } else {
        throw Exception('Error al crear usuario: ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al crear usuario: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data?['message'] ?? 
                      error.response!.data?['error'] ?? 
                      'Error del servidor';
      
      return Exception('[$statusCode] $message');
    } else {
      return Exception(error.message ?? 'Error de conexión');
    }
  }
}
