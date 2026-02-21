import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de autenticación — usa Supabase Auth + tabla profiles.
class AuthProvider {
  SupabaseClient get _client => ApiClient.supabase;
  GoTrueClient get _auth => ApiClient.auth;

  /// Iniciar sesión con email y contraseña.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(email: email, password: password);
  }

  /// Registrar un nuevo usuario con email y contraseña.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    return await _auth.signUp(email: email, password: password, data: metadata);
  }

  /// Obtener la sesión actual del usuario.
  Session? get currentSession => _auth.currentSession;

  /// Obtener el usuario actual.
  User? get currentUser => _auth.currentUser;

  /// Cerrar sesión.
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Escuchar cambios en el estado de autenticación.
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// Enviar email de recuperación de contraseña.
  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Actualizar datos del usuario (metadata de Auth).
  Future<UserResponse> updateUserData(Map<String, dynamic> data) async {
    return await _auth.updateUser(UserAttributes(data: data));
  }

  /// Obtener el perfil completo del usuario actual (profile + company)
  /// mediante la RPC `get_my_profile()`.
  Future<Map<String, dynamic>?> getFullProfile() async {
    final response = await _client.rpc('get_my_profile');
    if (response == null) return null;
    return Map<String, dynamic>.from(response as Map);
  }

  /// Actualizar datos del perfil en la tabla `profiles`.
  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _client.from('profiles').update(data).eq('id', userId);
  }
}
