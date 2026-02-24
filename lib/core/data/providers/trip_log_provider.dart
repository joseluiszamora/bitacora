import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de logs de viaje — operaciones CRUD directas contra Supabase.
class TripLogProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('trip_logs');

  /// Selector con joins para las relaciones.
  static const _selectWithJoins =
      '*, '
      'user:profiles!trip_logs_user_id_fkey(*), '
      'driver:profiles!trip_logs_driver_id_fkey(*), '
      'media:trip_log_media(*)';

  /// Obtener todos los logs de un viaje con joins.
  Future<List<Map<String, dynamic>>> getByTrip(String tripId) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('trip_id', tripId)
          .order('created_at', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        // Fallback sin joins a media si la tabla no existe aún.
        final response = await _table
            .select(
              '*, user:profiles!trip_logs_user_id_fkey(*), '
              'driver:profiles!trip_logs_driver_id_fkey(*)',
            )
            .eq('trip_id', tripId)
            .order('created_at', ascending: true);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener un log por su ID con joins.
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
            .select(
              '*, user:profiles!trip_logs_user_id_fkey(*), '
              'driver:profiles!trip_logs_driver_id_fkey(*)',
            )
            .eq('id', id)
            .maybeSingle();
        return response;
      }
      rethrow;
    }
  }

  /// Crear un nuevo log.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un log existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un log por ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
