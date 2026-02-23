import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de documentos de vehículo — CRUD directo contra Supabase.
class VehicleDocumentProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table =>
      ApiClient.supabase.from('vehicle_documents');

  /// Obtener todos los documentos de un vehículo.
  Future<List<Map<String, dynamic>>> getByVehicle(String vehicleId) async {
    final response = await _table
        .select()
        .eq('vehicle_id', vehicleId)
        .order('type', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener un documento por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table.select().eq('id', id).maybeSingle();
    return response;
  }

  /// Crear un nuevo documento.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un documento existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un documento por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
