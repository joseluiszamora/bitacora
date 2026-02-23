import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de ciudades — solo lectura contra Supabase.
class CityProvider {
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('cities');

  /// Obtener todas las ciudades con estado/departamento.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table
        .select('*, state:states(*)')
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener ciudades filtradas por estado.
  Future<List<Map<String, dynamic>>> getByState(int stateId) async {
    final response = await _table
        .select('*, state:states(*)')
        .eq('state_id', stateId)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener una ciudad por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table
        .select('*, state:states(*)')
        .eq('id', id)
        .maybeSingle();
    return response;
  }
}
