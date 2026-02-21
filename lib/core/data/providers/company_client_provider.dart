import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de relaciones transportista ↔ cliente — CRUD contra Supabase.
class CompanyClientProvider {
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('company_clients');

  /// Obtener todas las relaciones con joins a companies y client_companies.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table
        .select('*, company:companies(*), client_company:client_companies(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener relaciones de una transportista específica.
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final response = await _table
        .select('*, company:companies(*), client_company:client_companies(*)')
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener relaciones de una empresa cliente específica.
  Future<List<Map<String, dynamic>>> getByClientCompany(
    String clientCompanyId,
  ) async {
    final response = await _table
        .select('*, company:companies(*), client_company:client_companies(*)')
        .eq('client_company_id', clientCompanyId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener una relación por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table
        .select('*, company:companies(*), client_company:client_companies(*)')
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crear una nueva relación transportista ↔ cliente.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table
        .insert(data)
        .select('*, company:companies(*), client_company:client_companies(*)')
        .single();
    return response;
  }

  /// Actualizar una relación existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table
        .update(data)
        .eq('id', id)
        .select('*, company:companies(*), client_company:client_companies(*)')
        .single();
    return response;
  }

  /// Eliminar una relación por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
