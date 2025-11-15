import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Eventos del Auth BLoC
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Iniciar sesión
class SignInRequested extends AuthEvent {
  final String username;
  final String password;

  const SignInRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}

/// Evento: Registrarse
class SignUpRequested extends AuthEvent {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final Uint8List? photoBytes;
  final String? photoFileName;

  const SignUpRequested({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoBytes,
    this.photoFileName,
  });

  @override
  List<Object?> get props => [
        username,
        password,
        firstName,
        lastName,
        email,
        photoBytes,
        photoFileName,
      ];
}

/// Evento: Cerrar sesión
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Evento: Verificar autenticación
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
