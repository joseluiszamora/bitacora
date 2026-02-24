import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de media de logs de viaje — operaciones CRUD contra Supabase.
class TripLogMediaProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('trip_log_media');

  /// Obtener todos los media de un log.
  Future<List<Map<String, dynamic>>> getByTripLog(String tripLogId) async {
    final response = await _table
        .select()
        .eq('trip_log_id', tripLogId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Crear un nuevo media.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Eliminar un media por ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }

  /// Eliminar todos los media de un log.
  Future<void> deleteByTripLog(String tripLogId) async {
    await _table.delete().eq('trip_log_id', tripLogId);
  }
}
