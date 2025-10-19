import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

/// Estados del Auth BLoC
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Cargando
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Autenticado (Login exitoso)
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// No autenticado
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Registro exitoso
class SignUpSuccess extends AuthState {
  final String message;

  const SignUpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
