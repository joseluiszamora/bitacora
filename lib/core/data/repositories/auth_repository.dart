import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../models/user.dart';
import '../providers/auth_provider.dart';

/// Repositorio de autenticación.
///
/// Orquesta Supabase Auth y expone streams reactivos
/// para que el AuthenticationBloc escuche cambios de sesión.
class AuthRepository {
  AuthRepository({AuthProvider? authProvider})
    : _authProvider = authProvider ?? AuthProvider();

  final AuthProvider _authProvider;

  /// Stream que emite cada cambio de estado de autenticación.
  Stream<sb.AuthState> get onAuthStateChange => _authProvider.onAuthStateChange;

  /// Inicio de sesión con email y contraseña.
  Future<User> login({required String email, required String password}) async {
    final response = await _authProvider.login(
      email: email,
      password: password,
    );

    final supabaseUser = response.user;
    if (supabaseUser == null) {
      throw Exception('No se pudo autenticar al usuario.');
    }

    return User.fromSupabaseUser(supabaseUser);
  }

  /// Registro de nuevo usuario.
  Future<User> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _authProvider.signUp(
      email: email,
      password: password,
      metadata: name != null ? {'name': name} : null,
    );

    final supabaseUser = response.user;
    if (supabaseUser == null) {
      throw Exception('No se pudo registrar al usuario.');
    }

    return User.fromSupabaseUser(supabaseUser);
  }

  /// Obtener el usuario actual desde la sesión de Supabase.
  User getCurrentUser() {
    final supabaseUser = _authProvider.currentUser;
    if (supabaseUser == null) return User.empty;
    return User.fromSupabaseUser(supabaseUser);
  }

  /// Verificar si hay una sesión activa.
  bool get isAuthenticated => _authProvider.currentSession != null;

  /// Cerrar sesión.
  Future<void> logout() async {
    try {
      await _authProvider.logout();
    } catch (e) {
      debugPrint('⚠️ Error al cerrar sesión: $e');
    }
  }

  /// Enviar email de recuperación de contraseña.
  Future<void> resetPassword(String email) async {
    await _authProvider.resetPassword(email);
  }

  /// Actualizar datos del perfil del usuario.
  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _authProvider.updateUserData(data);
    final updatedUser = response.user;
    if (updatedUser == null) {
      throw Exception('No se pudo actualizar el perfil.');
    }
    return User.fromSupabaseUser(updatedUser);
  }
}
