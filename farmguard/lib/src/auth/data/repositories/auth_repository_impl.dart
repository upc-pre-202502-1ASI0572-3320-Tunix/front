import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/sign_in_request.dart';
import '../models/sign_up_request.dart';

/// Implementación del Repository
/// Coordina entre DataSources (remoto y local)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final request = SignInRequest(
        username: username,
        password: password,
      );

      final response = await remoteDataSource.signIn(request);

      // Guardar token
      await TokenStorage.saveToken(response.token);

      // Convertir a UserModel y cachear
      final userModel = response.toUserModel();
      await localDataSource.cacheUser(userModel);

      // Retornar Entity
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    String? urlPhoto,
  }) async {
    try {
      final request = SignUpRequest(
        username: username,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        urlPhoto: urlPhoto,
      );

      final response = await remoteDataSource.signUp(request);

      return Right(response.message);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Limpiar token y cache
      await TokenStorage.clearTokens();
      await localDataSource.clearCache();

      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await TokenStorage.hasToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    final userModel = await localDataSource.getCachedUser();
    return userModel?.toEntity();
  }

  Failure _handleError(Object error) {
    final errorMessage = error.toString();

    if (errorMessage.contains('[401]') || errorMessage.contains('[403]')) {
      return AuthFailure(
        message: 'Credenciales inválidas',
        statusCode: 401,
      );
    }

    if (errorMessage.contains('[400]')) {
      return ValidationFailure(
        message: errorMessage.replaceAll('[400]', '').trim(),
      );
    }

    if (errorMessage.contains('[500]') || errorMessage.contains('[502]')) {
      return ServerFailure(
        message: 'Error del servidor. Intente más tarde.',
        statusCode: 500,
      );
    }

    if (errorMessage.contains('conexión') || 
        errorMessage.contains('connection') ||
        errorMessage.contains('network')) {
      return const ConnectionFailure(
        message: 'Sin conexión a internet',
      );
    }

    return UnknownFailure(message: errorMessage);
  }
}
