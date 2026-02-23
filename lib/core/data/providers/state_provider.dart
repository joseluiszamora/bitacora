import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de estados/departamentos — solo lectura contra Supabase.
class StateProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('states');

  /// Obtener todos los estados.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table.select().order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener estados filtrados por código de país.
  Future<List<Map<String, dynamic>>> getByCountryCode(
    String countryCode,
  ) async {
    final response = await _table
        .select()
        .eq('country_code', countryCode)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener un estado por su ID.
  Future<Map<String, dynamic>?> getById(int id) async {
    final response = await _table.select().eq('id', id).maybeSingle();
    return response;
  }
}
