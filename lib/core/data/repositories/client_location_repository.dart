import 'package:flutter/foundation.dart';

import '../models/client_location.dart';
import '../providers/client_location_provider.dart';

/// Repositorio de ubicaciones de clientes.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class ClientLocationRepository {
  ClientLocationRepository({ClientLocationProvider? provider})
    : _provider = provider ?? ClientLocationProvider();

  final ClientLocationProvider _provider;

  /// Obtener todas las ubicaciones.
  Future<List<ClientLocation>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(ClientLocation.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo ubicaciones: $e');
      rethrow;
    }
  }

  /// Obtener ubicaciones por empresa cliente.
  Future<List<ClientLocation>> getByClientCompany(
    String clientCompanyId,
  ) async {
    try {
      final data = await _provider.getByClientCompany(clientCompanyId);
      return data.map(ClientLocation.fromJson).toList();
    } catch (e) {
      debugPrint(
        '❌ Error obteniendo ubicaciones del cliente $clientCompanyId: $e',
      );
      rethrow;
    }
  }

  /// Obtener una ubicación por su ID.
  Future<ClientLocation?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return ClientLocation.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo ubicación $id: $e');
      rethrow;
    }
  }

  /// Crear una nueva ubicación.
  Future<ClientLocation> create({
    required String clientCompanyId,
    required String name,
    required ClientLocationType type,
    String? address,
    String? cityId,
    String country = 'Bolivia',
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
  }) async {
    try {
      final payload = <String, dynamic>{
        'client_company_id': clientCompanyId,
        'name': name,
        'type': type.value,
        'country': country,
        'status': ClientLocationStatus.active.value,
      };
      if (address != null) payload['address'] = address;
      if (cityId != null) payload['city_id'] = cityId;
      if (latitude != null) payload['latitude'] = latitude;
      if (longitude != null) payload['longitude'] = longitude;
      if (contactName != null) payload['contact_name'] = contactName;
      if (contactPhone != null) payload['contact_phone'] = contactPhone;

      final data = await _provider.create(payload);
      return ClientLocation.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando ubicación: $e');
      rethrow;
    }
  }

  /// Actualizar una ubicación existente.
  Future<ClientLocation> update({
    required String id,
    String? clientCompanyId,
    String? name,
    ClientLocationType? type,
    String? address,
    String? cityId,
    String? country,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    ClientLocationStatus? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (clientCompanyId != null) {
        updates['client_company_id'] = clientCompanyId;
      }
      if (name != null) updates['name'] = name;
      if (type != null) updates['type'] = type.value;
      if (address != null) updates['address'] = address;
      if (cityId != null) updates['city_id'] = cityId;
      if (country != null) updates['country'] = country;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (contactName != null) updates['contact_name'] = contactName;
      if (contactPhone != null) updates['contact_phone'] = contactPhone;
      if (status != null) updates['status'] = status.value;

      if (updates.isEmpty) {
        final existing = await getById(id);
        return existing ?? ClientLocation.empty;
      }

      final data = await _provider.update(id, updates);
      return ClientLocation.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando ubicación $id: $e');
      rethrow;
    }
  }

  /// Eliminar una ubicación por su ID.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando ubicación $id: $e');
      rethrow;
    }
  }
}
