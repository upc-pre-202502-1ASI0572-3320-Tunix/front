abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

// Errores de servidor
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

// Errores de conexión
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    required super.message,
  });
}

// Errores de autenticación
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
  });
}

// Errores de validación
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
  });
}

// Error de cache
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
  });
}

// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure({
    required super.message,
  });
}
