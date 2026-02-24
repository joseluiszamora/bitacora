import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de viajes — operaciones CRUD directas contra Supabase.
class TripProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table => ApiClient.supabase.from('trips');

  /// Selector con todos los joins necesarios.
  static const _selectWithJoins =
      '*, company:companies(*), '
      'client_company:client_companies(*), '
      'vehicle:vehicles(*), '
      'assigned_by:profiles!trips_assigned_by_user_id_fkey(*), '
      'origin_location:client_locations!trips_origin_location_id_fkey('
      '*, client_company:client_companies(*), city:cities(*, state:states(*))'
      '), '
      'destination_location:client_locations!trips_destination_location_id_fkey('
      '*, client_company:client_companies(*), city:cities(*, state:states(*))'
      ')';

  /// Selector sin join a cities/states (fallback si la tabla no existe aún).
  static const _selectBasic =
      '*, company:companies(*), '
      'client_company:client_companies(*), '
      'vehicle:vehicles(*), '
      'assigned_by:profiles!trips_assigned_by_user_id_fkey(*), '
      'origin_location:client_locations!trips_origin_location_id_fkey('
      '*, client_company:client_companies(*)'
      '), '
      'destination_location:client_locations!trips_destination_location_id_fkey('
      '*, client_company:client_companies(*)'
      ')';

  /// Obtener todos los viajes con joins.
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select(_selectBasic)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener viajes por empresa (transportista).
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('company_id', companyId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select(_selectBasic)
            .eq('company_id', companyId)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener viajes por empresa cliente.
  Future<List<Map<String, dynamic>>> getByClientCompany(
    String clientCompanyId,
  ) async {
    try {
      final response = await _table
          .select(_selectWithJoins)
          .eq('client_company_id', clientCompanyId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select(_selectBasic)
            .eq('client_company_id', clientCompanyId)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener viajes asignados a un driver (vía vehicle_assignments).
  ///
  /// Busca los vehicle_ids asignados al driver y filtra los viajes.
  Future<List<Map<String, dynamic>>> getByDriver(String driverId) async {
    // 1. Obtener los vehicle_ids asignados al driver (activos)
    final assignments = await ApiClient.supabase
        .from('vehicle_assignments')
        .select('vehicle_id')
        .eq('driver_id', driverId)
        .eq('is_active', true);

    final vehicleIds = List<Map<String, dynamic>>.from(
      assignments,
    ).map((a) => a['vehicle_id'] as String).toList();

    if (vehicleIds.isEmpty) return [];

    // 2. Obtener los viajes de esos vehículos
    try {
      final response = await _table
          .select(_selectWithJoins)
          .inFilter('vehicle_id', vehicleIds)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST200') {
        final response = await _table
            .select(_selectBasic)
            .inFilter('vehicle_id', vehicleIds)
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      }
      rethrow;
    }
  }

  /// Obtener un viaje por su ID.
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

  /// Crear un nuevo viaje.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar un viaje existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar un viaje por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
