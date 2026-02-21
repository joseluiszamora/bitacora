import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de usuarios — operaciones CRUD contra Supabase (profiles + auth).
class UserProvider {
  SupabaseClient get _client => ApiClient.supabase;
  SupabaseQueryBuilder get _profiles => _client.from('profiles');

  /// Obtener todos los perfiles con datos de su compañía y empresa cliente.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _profiles
        .select('*, company:companies(*), client_company:client_companies(*)')
        .order('full_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener perfiles filtrados por compañía (transportista).
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final response = await _profiles
        .select('*, company:companies(*), client_company:client_companies(*)')
        .eq('company_id', companyId)
        .order('full_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener perfiles filtrados por empresa cliente.
  Future<List<Map<String, dynamic>>> getByClientCompany(
    String clientCompanyId,
  ) async {
    final response = await _profiles
        .select('*, company:companies(*), client_company:client_companies(*)')
        .eq('client_company_id', clientCompanyId)
        .order('full_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener un perfil por su ID con datos de compañía y empresa cliente.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _profiles
        .select('*, company:companies(*), client_company:client_companies(*)')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crear un nuevo usuario vía Supabase Auth (signUp) +
  /// el trigger `on_auth_user_created` crea el perfil automáticamente.
  /// Luego actualiza el perfil con rol, compañía, etc.
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? companyId,
    String? clientCompanyId,
    String? phone,
  }) async {
    // 1. Crear usuario en Supabase Auth
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    final newUser = authResponse.user;
    if (newUser == null) {
      throw Exception('No se pudo crear el usuario en Auth.');
    }

    // 2. Actualizar el perfil (creado por el trigger) con rol y compañía
    final profileData = <String, dynamic>{
      'full_name': fullName,
      'role': role,
      'phone': phone,
    };
    if (companyId != null && companyId.isNotEmpty) {
      profileData['company_id'] = companyId;
    }
    if (clientCompanyId != null && clientCompanyId.isNotEmpty) {
      profileData['client_company_id'] = clientCompanyId;
    }

    await _profiles.update(profileData).eq('id', newUser.id);

    // 3. Retornar el perfil completo
    final profile = await getById(newUser.id);
    if (profile == null) {
      throw Exception('No se pudo obtener el perfil del nuevo usuario.');
    }
    return profile;
  }

  /// Actualizar datos del perfil de un usuario.
  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    final response = await _profiles
        .update(data)
        .eq('id', userId)
        .select('*, company:companies(*), client_company:client_companies(*)')
        .single();
    return response;
  }

  /// Activar o desactivar un usuario.
  Future<void> toggleActive(String userId, bool isActive) async {
    await _profiles.update({'is_active': isActive}).eq('id', userId);
  }

  /// Obtener el email de un usuario desde auth.users vía RPC.
  /// Necesitarás crear esta función en Supabase.
  Future<String?> getUserEmail(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_email',
        params: {'user_id': userId},
      );
      return response as String?;
    } catch (_) {
      return null;
    }
  }
}
