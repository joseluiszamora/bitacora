import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../data/repositories/auth_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

/// BLoC para el formulario de login.
///
/// Maneja validación, envío de credenciales a Supabase Auth,
/// y emite estados de carga, éxito o error.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
  }

  final AuthRepository _authRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, errorMessage: ''));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, errorMessage: ''));
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    // Validar campos
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: 'Completa todos los campos.'));
      return;
    }

    if (!_isValidEmail(state.email)) {
      emit(
        state.copyWith(errorMessage: 'Ingresa un correo electrónico válido.'),
      );
      return;
    }

    if (state.password.length < 6) {
      emit(
        state.copyWith(
          errorMessage: 'La contraseña debe tener al menos 6 caracteres.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: ''));

    try {
      await _authRepository.login(
        email: state.email.trim(),
        password: state.password,
      );

      // Supabase Auth emitirá el evento signedIn que el AuthenticationBloc
      // escuchará automáticamente — solo indicamos éxito aquí.
      emit(state.copyWith(status: LoginStatus.success));
    } on sb.AuthException catch (e) {
      debugPrint('❌ AuthException: ${e.message}');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: _mapAuthError(e.message),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error inesperado en login: $e');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Error inesperado. Intenta de nuevo.',
        ),
      );
    }
  }

  /// Valida formato de email.
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  /// Traduce errores de Supabase Auth a mensajes amigables en español.
  String _mapAuthError(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
    }
    if (lower.contains('too many requests') || lower.contains('rate limit')) {
      return 'Demasiados intentos. Espera un momento e intenta de nuevo.';
    }
    if (lower.contains('user not found')) {
      return 'No existe una cuenta con ese correo electrónico.';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Error de conexión. Verifica tu internet.';
    }

    return 'Error al iniciar sesión: $message';
  }
}
