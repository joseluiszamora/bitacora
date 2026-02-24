import 'package:flutter/foundation.dart';

import '../models/trip_log.dart';
import '../providers/trip_log_provider.dart';

/// Repositorio de logs de viaje.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class TripLogRepository {
  TripLogRepository({TripLogProvider? provider})
    : _provider = provider ?? TripLogProvider();

  final TripLogProvider _provider;

  /// Obtener todos los logs de un viaje.
  Future<List<TripLog>> getByTrip(String tripId) async {
    try {
      final data = await _provider.getByTrip(tripId);
      return data.map(TripLog.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo logs del viaje $tripId: $e');
      rethrow;
    }
  }

  /// Obtener un log por su ID.
  Future<TripLog?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return TripLog.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo log $id: $e');
      rethrow;
    }
  }

  /// Crear un nuevo log de viaje.
  Future<TripLog> create({
    required String tripId,
    String? userId,
    String? driverId,
    required TripLogEventType eventType,
    String? description,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final payload = <String, dynamic>{
        'trip_id': tripId,
        'event_type': eventType.value,
      };
      if (userId != null) payload['user_id'] = userId;
      if (driverId != null) payload['driver_id'] = driverId;
      if (description != null) payload['description'] = description;
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (metadata != null) payload['metadata'] = metadata;

      final data = await _provider.create(payload);
      return TripLog.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando log de viaje: $e');
      rethrow;
    }
  }

  /// Actualizar un log existente.
  Future<TripLog> update({
    required String id,
    String? userId,
    String? driverId,
    TripLogEventType? eventType,
    String? description,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (userId != null) updates['user_id'] = userId;
      if (driverId != null) updates['driver_id'] = driverId;
      if (eventType != null) updates['event_type'] = eventType.value;
      if (description != null) updates['description'] = description;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (metadata != null) updates['metadata'] = metadata;

      final data = await _provider.update(id, updates);
      return TripLog.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando log $id: $e');
      rethrow;
    }
  }

  /// Eliminar un log por ID.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando log $id: $e');
      rethrow;
    }
  }
}
