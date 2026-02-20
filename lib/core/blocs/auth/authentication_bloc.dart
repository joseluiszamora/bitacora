import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

/// BLoC de autenticación global.
class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository(),
      super(const AuthenticationState()) {
    on<AuthenticationStatusChecked>(_onStatusChecked);
    on<AuthenticationLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onStatusChecked(
    AuthenticationStatusChecked event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      final isAuth = await _authRepository.isAuthenticated();
      if (isAuth) {
        final user = await _authRepository.getProfile();
        emit(
          state.copyWith(
            status: AuthenticationStatus.authenticated,
            user: user,
          ),
        );
      } else {
        emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      }
    } on DioException catch (e) {
      debugPrint('❌ Error verificando autenticación: ${e.message}');
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
    } catch (e) {
      debugPrint('❌ Error inesperado: $e');
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
    }
  }

  Future<void> _onLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      await _authRepository.logout();
    } catch (_) {
      // Ignorar errores de logout — limpiar estado de todas formas
    }
    emit(
      const AuthenticationState(status: AuthenticationStatus.unauthenticated),
    );
  }
}
