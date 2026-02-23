import 'package:flutter/foundation.dart';

import '../models/trip.dart';
import '../providers/trip_provider.dart';

/// Repositorio de viajes.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class TripRepository {
  TripRepository({TripProvider? provider})
    : _provider = provider ?? TripProvider();

  final TripProvider _provider;

  /// Obtener todos los viajes.
  Future<List<Trip>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(Trip.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo viajes: $e');
      rethrow;
    }
  }

  /// Obtener viajes por empresa (transportista).
  Future<List<Trip>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(Trip.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo viajes de empresa $companyId: $e');
      rethrow;
    }
  }

  /// Obtener viajes por empresa cliente.
  Future<List<Trip>> getByClientCompany(String clientCompanyId) async {
    try {
      final data = await _provider.getByClientCompany(clientCompanyId);
      return data.map(Trip.fromJson).toList();
    } catch (e) {
      debugPrint(
        '❌ Error obteniendo viajes de empresa cliente $clientCompanyId: $e',
      );
      rethrow;
    }
  }

  /// Obtener un viaje por su ID.
  Future<Trip?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return Trip.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo viaje $id: $e');
      rethrow;
    }
  }

  /// Crear un nuevo viaje.
  Future<Trip> create({
    required String companyId,
    required String clientCompanyId,
    required String vehicleId,
    String? assignedByUserId,
    required String origin,
    required String destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    double? price,
  }) async {
    try {
      final payload = <String, dynamic>{
        'company_id': companyId,
        'client_company_id': clientCompanyId,
        'vehicle_id': vehicleId,
        'origin': origin,
        'destination': destination,
        'status': 'pending',
      };
      if (assignedByUserId != null) {
        payload['assigned_by_user_id'] = assignedByUserId;
      }
      if (departureTime != null) {
        payload['departure_time'] = departureTime.toIso8601String();
      }
      if (arrivalTime != null) {
        payload['arrival_time'] = arrivalTime.toIso8601String();
      }
      if (price != null) payload['price'] = price;

      final data = await _provider.create(payload);
      return Trip.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando viaje: $e');
      rethrow;
    }
  }

  /// Actualizar un viaje existente.
  Future<Trip> update({
    required String id,
    String? companyId,
    String? clientCompanyId,
    String? vehicleId,
    String? assignedByUserId,
    String? origin,
    String? destination,
    DateTime? departureTime,
    DateTime? arrivalTime,
    TripStatus? status,
    double? price,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (companyId != null) updates['company_id'] = companyId;
      if (clientCompanyId != null) {
        updates['client_company_id'] = clientCompanyId;
      }
      if (vehicleId != null) updates['vehicle_id'] = vehicleId;
      if (assignedByUserId != null) {
        updates['assigned_by_user_id'] = assignedByUserId;
      }
      if (origin != null) updates['origin'] = origin;
      if (destination != null) updates['destination'] = destination;
      if (departureTime != null) {
        updates['departure_time'] = departureTime.toIso8601String();
      }
      if (arrivalTime != null) {
        updates['arrival_time'] = arrivalTime.toIso8601String();
      }
      if (status != null) updates['status'] = status.value;
      if (price != null) updates['price'] = price;

      final data = await _provider.update(id, updates);
      return Trip.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando viaje $id: $e');
      rethrow;
    }
  }

  /// Eliminar un viaje.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando viaje $id: $e');
      rethrow;
    }
  }
}
