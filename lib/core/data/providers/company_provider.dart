import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de compañías — operaciones CRUD directas contra Supabase.
class CompanyProvider {
  /// Referencia fresca a la tabla en cada llamada para evitar
  /// problemas con instancias obsoletas del cliente.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('companies');

  /// Obtener todas las compañías ordenadas por nombre.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table.select().order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener una compañía por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table.select().eq('id', id).maybeSingle();
    return response;
  }

  /// Crear una nueva compañía.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar una compañía existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar una compañía por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
