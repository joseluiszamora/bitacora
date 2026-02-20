import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

/// BLoC de autenticación global.
///
/// Escucha los cambios de sesión de Supabase Auth de forma reactiva
/// y emite el estado correspondiente (authenticated / unauthenticated).
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const AuthenticationState()) {
    on<AuthenticationStatusChecked>(_onStatusChecked);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
    on<_AuthenticationStateChanged>(_onAuthStateChanged);

    // Escuchar cambios de sesión de Supabase en tiempo real
    _authSubscription = _authRepository.onAuthStateChange.listen((authState) {
      add(_AuthenticationStateChanged(authState.event));
    });
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<sb.AuthState> _authSubscription;

  /// Verificar el estado actual de autenticación.
  Future<void> _onStatusChecked(
    AuthenticationStatusChecked event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (_authRepository.isAuthenticated) {
        final user = _authRepository.getCurrentUser();
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: user,
          ),
        );
      } else {
        emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      }
    } catch (e) {
      debugPrint('❌ Error verificando autenticación: $e');
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
    }
  }

  /// Reaccionar a cambios del stream de Supabase Auth.
  void _onAuthStateChanged(
    _AuthenticationStateChanged event,
    Emitter<AuthenticationState> emit,
  ) {
    switch (event.event) {
      case sb.AuthChangeEvent.signedIn:
      case sb.AuthChangeEvent.tokenRefreshed:
      case sb.AuthChangeEvent.userUpdated:
        final user = _authRepository.getCurrentUser();
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: user,
          ),
        );
      case sb.AuthChangeEvent.signedOut:
        emit(
          const AuthenticationState(
            status: AuthenticationStatus.unauthenticated,
          ),
        );
      case sb.AuthChangeEvent.initialSession:
        if (_authRepository.isAuthenticated) {
          final user = _authRepository.getCurrentUser();
          emit(
            state.copyWith(
              status: AuthenticationStatus.authenticated,
              user: user,
            ),
          );
        } else {
          emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
        }
      default:
        break;
    }
  }

  /// Cerrar sesión.
  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    await _authRepository.logout();
    emit(
      const AuthenticationState(status: AuthenticationStatus.unauthenticated),
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
