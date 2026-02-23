import 'package:supabase_flutter/supabase_flutter.dart';

import '../api/api_client.dart';

/// Provider de asignaciones vehículo-conductor — CRUD contra Supabase.
class VehicleAssignmentProvider {
  /// Referencia fresca a la tabla en cada llamada.
  SupabaseQueryBuilder get _table =>
      ApiClient.supabase.from('vehicle_assignments');

  /// Selector con todos los joins necesarios.
  static const _selectWithJoins =
      '*, vehicle:vehicles(*, company:companies(*)), '
      'driver:profiles!vehicle_assignments_driver_id_fkey(*), '
      'assigned_by:profiles!vehicle_assignments_assigned_by_user_id_fkey(*)';

  /// Obtener todas las asignaciones con joins.
  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _table
        .select(_selectWithJoins)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener asignaciones por vehículo.
  Future<List<Map<String, dynamic>>> getByVehicle(String vehicleId) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('vehicle_id', vehicleId)
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener asignaciones por conductor.
  Future<List<Map<String, dynamic>>> getByDriver(String driverId) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('driver_id', driverId)
        .order('start_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener asignaciones por empresa (a través del vehículo).
  Future<List<Map<String, dynamic>>> getByCompany(String companyId) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('vehicle.company_id', companyId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener una asignación por su ID.
  Future<Map<String, dynamic>?> getById(String id) async {
    final response = await _table
        .select(_selectWithJoins)
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  /// Crear una nueva asignación.
  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final response = await _table.insert(data).select().single();
    return response;
  }

  /// Actualizar una asignación existente.
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _table.update(data).eq('id', id).select().single();
    return response;
  }

  /// Eliminar una asignación por su ID.
  Future<void> delete(String id) async {
    await _table.delete().eq('id', id);
  }
}
