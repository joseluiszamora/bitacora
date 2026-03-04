import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de registros/movimientos financieros — CRUD contra Supabase.
class FinanceRecordProvider {
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('finance_records');

  /// Select con joins a grupos, categorías y usuario responsable.
  static const _selectWithJoins = '''
    *,
    finance_groups!inner(id, name),
    finance_categories!inner(id, name),
    responsible_user:profiles!finance_records_responsible_user_id_fkey(id, full_name)
  ''';

  /// Obtener todos los registros de una empresa con joins.
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('company_id', companyId)
          .order('record_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      // Fallback PGRST200: reintentar sin joins anidados.
      if (e.code == 'PGRST200') {
        final response = await _table
            .select()
            .eq('company_id', companyId)
            .order('record_date', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener registros por grupo.
  Future<List<Map<String, dynamic>>> getByGroup(String groupId) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('group_id', groupId)
          .order('record_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select()
            .eq('group_id', groupId)
            .order('record_date', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener un registro por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('id', id)
          .maybeSingle();
      return response;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table.select().eq('id', id).maybeSingle();
        return response;
      }
      rethrow;
    }
  }

  /// Crear un nuevo registro.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un registro existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un registro por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
