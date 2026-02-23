import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de viajes — operaciones CRUD directas contra Supabase.
class TripProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('trips');

  /// Selector con todos los joins necesarios.
  static const _selectWithJoins =
      '*, company:companies(*), '
      'client_company:client_companies(*), '
      'vehicle:vehicles(*), '
      'assigned_by:profiles!trips_assigned_by_user_id_fkey(*)';

  /// Obtener todos los viajes con joins.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table
        .select(_selectWithJoins)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener viajes por empresa (transportista).
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener viajes por empresa cliente.
  Future<List<Map<String, dynamic>>> getByClientCompany(
    String clientCompanyId,
  ) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('client_company_id', clientCompanyId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener un viaje por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crear un nuevo viaje.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un viaje existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un viaje por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
