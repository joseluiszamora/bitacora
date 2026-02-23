import 'package:flutter/foundation.dart';

import '../models/vehicle_assignment.dart';
import '../providers/vehicle_assignment_provider.dart';

/// Repositorio de asignaciones vehículo-conductor.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class VehicleAssignmentRepository {
  VehicleAssignmentRepository({VehicleAssignmentProvider? provider})
    : _provider = provider ?? VehicleAssignmentProvider();

  final VehicleAssignmentProvider _provider;

  /// Obtener todas las asignaciones.
  Future<List<VehicleAssignment>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(VehicleAssignment.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo asignaciones: $e');
      rethrow;
    }
  }

  /// Obtener asignaciones por vehículo.
  Future<List<VehicleAssignment>> getByVehicle(String vehicleId) async {
    try {
      final data = await _provider.getByVehicle(vehicleId);
      return data.map(VehicleAssignment.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo asignaciones del vehículo $vehicleId: $e');
      rethrow;
    }
  }

  /// Obtener asignaciones por conductor.
  Future<List<VehicleAssignment>> getByDriver(String driverId) async {
    try {
      final data = await _provider.getByDriver(driverId);
      return data.map(VehicleAssignment.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo asignaciones del conductor $driverId: $e');
      rethrow;
    }
  }

  /// Obtener asignaciones por empresa.
  Future<List<VehicleAssignment>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(VehicleAssignment.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo asignaciones de empresa $companyId: $e');
      rethrow;
    }
  }

  /// Obtener una asignación por su ID.
  Future<VehicleAssignment?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return VehicleAssignment.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo asignación $id: $e');
      rethrow;
    }
  }

  /// Crear una nueva asignación.
  Future<VehicleAssignment> create({
    required String vehicleId,
    required String driverId,
    String? assignedByUserId,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final payload = <String, dynamic>{
        'vehicle_id': vehicleId,
        'driver_id': driverId,
        'start_date': startDate.toIso8601String(),
        'is_active': true,
      };
      if (assignedByUserId != null) {
        payload['assigned_by_user_id'] = assignedByUserId;
      }
      if (endDate != null) {
        payload['end_date'] = endDate.toIso8601String();
      }

      final data = await _provider.create(payload);
      return VehicleAssignment.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando asignación: $e');
      rethrow;
    }
  }

  /// Actualizar una asignación existente.
  Future<VehicleAssignment> update({
    required String id,
    String? vehicleId,
    String? driverId,
    String? assignedByUserId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (vehicleId != null) updates['vehicle_id'] = vehicleId;
      if (driverId != null) updates['driver_id'] = driverId;
      if (assignedByUserId != null) {
        updates['assigned_by_user_id'] = assignedByUserId;
      }
      if (startDate != null) {
        updates['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        updates['end_date'] = endDate.toIso8601String();
      }
      if (isActive != null) updates['is_active'] = isActive;

      final data = await _provider.update(id, updates);
      return VehicleAssignment.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando asignación $id: $e');
      rethrow;
    }
  }

  /// Finalizar una asignación (desactivar y poner fecha de fin).
  Future<VehicleAssignment> endAssignment(String id) async {
    try {
      final updates = <String, dynamic>{
        'is_active': false,
        'end_date': DateTime.now().toIso8601String(),
      };
      final data = await _provider.update(id, updates);
      return VehicleAssignment.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error finalizando asignación $id: $e');
      rethrow;
    }
  }

  /// Eliminar una asignación.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando asignación $id: $e');
      rethrow;
    }
  }
}
