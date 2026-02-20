part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// El usuario cambió el email en el formulario.
final class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// El usuario cambió la contraseña en el formulario.
final class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => [password];
}

/// El usuario envió el formulario de login.
final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

/// Alternar visibilidad de la contraseña.
final class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}
