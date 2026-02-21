import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de empresas cliente — operaciones CRUD contra Supabase.
class ClientCompanyProvider {
  SupabaseQueryBuilder get _table =>
      ApiClient.supabase.from('client_companies');

  /// Obtener todas las empresas cliente ordenadas por nombre.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table.select().order('name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener una empresa cliente por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table.select().eq('id', id).maybeSingle();
    return response;
  }

  /// Crear una nueva empresa cliente.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar una empresa cliente existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar una empresa cliente por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
