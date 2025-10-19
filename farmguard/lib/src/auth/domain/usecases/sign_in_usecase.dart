import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use Case para Login
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
  }) async {
    // Validaciones de negocio
    if (username.isEmpty) {
      return const Left(
        ValidationFailure(message: 'El nombre de usuario es requerido'),
      );
    }

    if (password.isEmpty) {
      return const Left(
        ValidationFailure(message: 'La contraseña es requerida'),
      );
    }

    if (password.length < 6) {
      return const Left(
        ValidationFailure(message: 'La contraseña debe tener al menos 6 caracteres'),
      );
    }

    return await repository.signIn(
      username: username,
      password: password,
    );
  }
}
