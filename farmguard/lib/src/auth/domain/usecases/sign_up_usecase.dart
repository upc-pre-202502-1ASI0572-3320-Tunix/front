import 'dart:typed_data';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use Case para Register
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    // Validaciones de negocio
    if (username.isEmpty) {
      return const Left(
        ValidationFailure(message: 'El nombre de usuario es requerido'),
      );
    }

    if (username.length < 3) {
      return const Left(
        ValidationFailure(message: 'El nombre de usuario debe tener al menos 3 caracteres'),
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

    if (firstName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'El nombre es requerido'),
      );
    }

    if (lastName.isEmpty) {
      return const Left(
        ValidationFailure(message: 'El apellido es requerido'),
      );
    }

    if (email.isEmpty) {
      return const Left(
        ValidationFailure(message: 'El email es requerido'),
      );
    }

    // Validación básica de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(
        ValidationFailure(message: 'El email no es válido'),
      );
    }

    return await repository.signUp(
      username: username,
      password: password,
      firstName: firstName,
      lastName: lastName,
      email: email,
      photoBytes: photoBytes,
      photoFileName: photoFileName,
    );
  }
}
