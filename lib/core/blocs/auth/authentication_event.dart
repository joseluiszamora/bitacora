part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

/// Verificar el estado de autenticación al iniciar la app.
final class AuthenticationStatusChecked extends AuthenticationEvent {
  const AuthenticationStatusChecked();
}

/// El usuario cerró sesión.
final class AuthenticationLogoutRequested extends AuthenticationEvent {
  const AuthenticationLogoutRequested();
}
