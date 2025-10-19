import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
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
      final response = await apiClient.post(
        ApiConstants.signUp,
        data: request.toJson(),
      );

      return SignUpResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
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
