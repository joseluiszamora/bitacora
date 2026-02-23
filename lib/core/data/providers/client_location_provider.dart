import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de ubicaciones de clientes — CRUD contra Supabase.
class ClientLocationProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table =>
      ApiClient.supabase.from('client_locations');

  /// Selector con todos los joins necesarios.
  ///
  /// NOTA: El join a `cities` requiere que la tabla exista en Supabase
  /// y que `client_locations.city_id` tenga un FK a `cities(id)`.
  /// Si `cities` aún no fue creada, usar [_selectBasic].
  static const _selectWithJoins =
      '*, client_company:client_companies(*), city:cities(*, state:states(*))';

  /// Selector sin join a cities (fallback).
  static const _selectBasic = '*, client_company:client_companies(*)';

  /// Obtener todas las ubicaciones con joins.
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        // Fallback: la tabla cities no existe aún
        final response = await _table
            .select(_selectBasic)
            .order('name', ascending: true);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener ubicaciones por empresa cliente.
  Future<List<Map<String, dynamic>>> getByClientCompany(
    String clientCompanyId,
  ) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('client_company_id', clientCompanyId)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select(_selectBasic)
            .eq('client_company_id', clientCompanyId)
            .order('name', ascending: true);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener una ubicación por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('id', id)
          .maybeSingle();
      return response;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select(_selectBasic)
            .eq('id', id)
            .maybeSingle();
        return response;
      }
      rethrow;
    }
  }

  /// Crear una nueva ubicación.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar una ubicación existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar una ubicación por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
