import 'package:flutter/foundation.dart';

import '../models/vehicle.dart';
import '../providers/vehicle_provider.dart';

/// Repositorio de vehículos.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class VehicleRepository {
  VehicleRepository({VehicleProvider? provider})
    : _provider = provider ?? VehicleProvider();

  final VehicleProvider _provider;

  /// Obtener todos los vehículos.
  Future<List<Vehicle>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(Vehicle.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo vehículos: $e');
      rethrow;
    }
  }

  /// Obtener vehículos por empresa.
  Future<List<Vehicle>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(Vehicle.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo vehículos de empresa $companyId: $e');
      rethrow;
    }
  }

  /// Obtener un vehículo por su ID.
  Future<Vehicle?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return Vehicle.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo vehículo $id: $e');
      rethrow;
    }
  }

  /// Crear un nuevo vehículo.
  Future<Vehicle> create({
    required String companyId,
    required String plateNumber,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? avatarUrl,
    String? chasisCode,
    String? motorCode,
    String? ruatNumber,
    DateTime? soatExpirationDate,
    DateTime? inspectionExpirationDate,
    DateTime? insuranceExpirationDate,
  }) async {
    try {
      final payload = <String, dynamic>{
        'company_id': companyId,
        'plate_number': plateNumber,
        'status': 'active',
      };
      if (brand != null) payload['brand'] = brand;
      if (model != null) payload['model'] = model;
      if (year != null) payload['year'] = year;
      if (color != null) payload['color'] = color;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;
      if (chasisCode != null) payload['chasis_code'] = chasisCode;
      if (motorCode != null) payload['motor_code'] = motorCode;
      if (ruatNumber != null) payload['ruat_number'] = ruatNumber;
      if (soatExpirationDate != null) {
        payload['soat_expiration_date'] = soatExpirationDate.toIso8601String();
      }
      if (inspectionExpirationDate != null) {
        payload['inspection_expiration_date'] = inspectionExpirationDate
            .toIso8601String();
      }
      if (insuranceExpirationDate != null) {
        payload['insurance_expiration_date'] = insuranceExpirationDate
            .toIso8601String();
      }

      final data = await _provider.create(payload);
      return Vehicle.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando vehículo: $e');
      rethrow;
    }
  }

  /// Actualizar un vehículo existente.
  Future<Vehicle> update({
    required String id,
    String? companyId,
    String? plateNumber,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? avatarUrl,
    String? chasisCode,
    String? motorCode,
    String? ruatNumber,
    DateTime? soatExpirationDate,
    DateTime? inspectionExpirationDate,
    DateTime? insuranceExpirationDate,
    VehicleStatus? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (companyId != null) updates['company_id'] = companyId;
      if (plateNumber != null) updates['plate_number'] = plateNumber;
      if (brand != null) updates['brand'] = brand;
      if (model != null) updates['model'] = model;
      if (year != null) updates['year'] = year;
      if (color != null) updates['color'] = color;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (chasisCode != null) updates['chasis_code'] = chasisCode;
      if (motorCode != null) updates['motor_code'] = motorCode;
      if (ruatNumber != null) updates['ruat_number'] = ruatNumber;
      if (soatExpirationDate != null) {
        updates['soat_expiration_date'] = soatExpirationDate.toIso8601String();
      }
      if (inspectionExpirationDate != null) {
        updates['inspection_expiration_date'] = inspectionExpirationDate
            .toIso8601String();
      }
      if (insuranceExpirationDate != null) {
        updates['insurance_expiration_date'] = insuranceExpirationDate
            .toIso8601String();
      }
      if (status != null) updates['status'] = status.value;

      final data = await _provider.update(id, updates);
      return Vehicle.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando vehículo $id: $e');
      rethrow;
    }
  }

  /// Eliminar un vehículo.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando vehículo $id: $e');
      rethrow;
    }
  }
}
