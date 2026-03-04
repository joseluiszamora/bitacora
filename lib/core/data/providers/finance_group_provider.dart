import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de grupos financieros — operaciones CRUD contra Supabase.
class FinanceGroupProvider {
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('finance_groups');

  /// Obtener todos los grupos de una empresa ordenados por nombre.
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final response = await _table
        .select()
        .eq('company_id', companyId)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener solo grupos activos de una empresa.
  Future<List<Map<String, dynamic>>> getActiveByCompany(
    String companyId,
  ) async {
    final response = await _table
        .select()
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener un grupo por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table.select().eq('id', id).maybeSingle();
    return response;
  }

  /// Crear un nuevo grupo.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un grupo existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un grupo por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
