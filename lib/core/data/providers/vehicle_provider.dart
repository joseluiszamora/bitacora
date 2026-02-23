import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de vehículos — operaciones CRUD directas contra Supabase.
class VehicleProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('vehicles');

  /// Obtener todos los vehículos con join a companies.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table
        .select('*, company:companies(*)')
        .order('plate_number', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener vehículos por empresa.
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final response = await _table
        .select('*, company:companies(*)')
        .eq('company_id', companyId)
        .order('plate_number', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener un vehículo por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table
        .select('*, company:companies(*)')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crear un nuevo vehículo.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un vehículo existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un vehículo por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
