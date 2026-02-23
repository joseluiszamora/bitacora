import 'package:flutter/foundation.dart';

import '../models/vehicle_document.dart';
import '../providers/vehicle_document_provider.dart';

/// Repositorio de documentos de vehículo.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class VehicleDocumentRepository {
  VehicleDocumentRepository({VehicleDocumentProvider? provider})
    : _provider = provider ?? VehicleDocumentProvider();

  final VehicleDocumentProvider _provider;

  /// Obtener todos los documentos de un vehículo.
  Future<List<VehicleDocument>> getByVehicle(String vehicleId) async {
    try {
      final data = await _provider.getByVehicle(vehicleId);
      return data.map(VehicleDocument.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo documentos del vehículo $vehicleId: $e');
      rethrow;
    }
  }

  /// Obtener un documento por su ID.
  Future<VehicleDocument?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return VehicleDocument.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo documento $id: $e');
      rethrow;
    }
  }

  /// Crear un nuevo documento.
  Future<VehicleDocument> create({
    required String vehicleId,
    required VehicleDocumentType type,
    String? fileUrl,
    DateTime? expirationDate,
  }) async {
    try {
      final payload = <String, dynamic>{
        'vehicle_id': vehicleId,
        'type': type.value,
      };
      if (fileUrl != null) payload['file_url'] = fileUrl;
      if (expirationDate != null) {
        payload['expiration_date'] = expirationDate.toIso8601String();
      }

      final data = await _provider.create(payload);
      return VehicleDocument.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando documento: $e');
      rethrow;
    }
  }

  /// Actualizar un documento existente.
  Future<VehicleDocument> update({
    required String id,
    VehicleDocumentType? type,
    String? fileUrl,
    DateTime? expirationDate,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (type != null) updates['type'] = type.value;
      if (fileUrl != null) updates['file_url'] = fileUrl;
      if (expirationDate != null) {
        updates['expiration_date'] = expirationDate.toIso8601String();
      }

      final data = await _provider.update(id, updates);
      return VehicleDocument.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando documento $id: $e');
      rethrow;
    }
  }

  /// Eliminar un documento.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando documento $id: $e');
      rethrow;
    }
  }
}
