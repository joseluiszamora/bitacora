import 'package:flutter/foundation.dart';

import '../models/trip_log_media.dart';
import '../providers/trip_log_media_provider.dart';

/// Repositorio de media de logs de viaje.
class TripLogMediaRepository {
  TripLogMediaRepository({TripLogMediaProvider? provider})
    : _provider = provider ?? TripLogMediaProvider();

  final TripLogMediaProvider _provider;

  /// Obtener todos los media de un log.
  Future<List<TripLogMedia>> getByTripLog(String tripLogId) async {
    try {
      final data = await _provider.getByTripLog(tripLogId);
      return data.map(TripLogMedia.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo media del log $tripLogId: $e');
      rethrow;
    }
  }

  /// Crear un nuevo media.
  Future<TripLogMedia> create({
    required String tripLogId,
    required String url,
    TripLogMediaType type = TripLogMediaType.photo,
    String? caption,
  }) async {
    try {
      final payload = <String, dynamic>{
        'trip_log_id': tripLogId,
        'url': url,
        'type': type.value,
      };
      if (caption != null) payload['caption'] = caption;

      final data = await _provider.create(payload);
      return TripLogMedia.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando media: $e');
      rethrow;
    }
  }

  /// Eliminar un media por ID.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando media $id: $e');
      rethrow;
    }
  }

  /// Eliminar todos los media de un log.
  Future<void> deleteByTripLog(String tripLogId) async {
    try {
      await _provider.deleteByTripLog(tripLogId);
    } catch (e) {
      debugPrint('❌ Error eliminando media del log $tripLogId: $e');
      rethrow;
    }
  }
}
