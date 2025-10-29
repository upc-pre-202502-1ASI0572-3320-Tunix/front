import 'dart:typed_data';
import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Contrato del Repository (Domain Layer)
/// Define QUÉ operaciones se pueden hacer, no CÓMO
abstract class AuthRepository {
  /// Iniciar sesión
  Future<Either<Failure, User>> signIn({
    required String username,
    required String password,
  });

  /// Registrar nuevo usuario
  Future<Either<Failure, String>> signUp({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    Uint8List? photoBytes,
    String? photoFileName,
  });

  /// Cerrar sesión
  Future<Either<Failure, void>> logout();

  /// Verificar si el usuario está autenticado
  Future<bool> isAuthenticated();

  /// Obtener usuario actual (desde cache/storage)
  Future<User?> getCurrentUser();
}
