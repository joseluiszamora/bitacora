import 'package:flutter/foundation.dart';

import '../models/company_client.dart';
import '../providers/company_client_provider.dart';

/// Repositorio de relaciones transportista ↔ cliente.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class CompanyClientRepository {
  CompanyClientRepository({CompanyClientProvider? provider})
    : _provider = provider ?? CompanyClientProvider();

  final CompanyClientProvider _provider;

  /// Obtener todas las relaciones.
  Future<List<CompanyClient>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(CompanyClient.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo relaciones transportista-cliente: $e');
      rethrow;
    }
  }

  /// Obtener relaciones de una transportista.
  Future<List<CompanyClient>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(CompanyClient.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo clientes de transportista: $e');
      rethrow;
    }
  }

  /// Obtener relaciones de una empresa cliente.
  Future<List<CompanyClient>> getByClientCompany(String clientCompanyId) async {
    try {
      final data = await _provider.getByClientCompany(clientCompanyId);
      return data.map(CompanyClient.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo transportistas del cliente: $e');
      rethrow;
    }
  }

  /// Crear una nueva relación transportista ↔ cliente.
  Future<CompanyClient> create({
    required String companyId,
    required String clientCompanyId,
    String? contractType,
    String status = 'active',
  }) async {
    try {
      final data = await _provider.create({
        'company_id': companyId,
        'client_company_id': clientCompanyId,
        'contract_type': contractType,
        'status': status,
      });
      return CompanyClient.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando relación transportista-cliente: $e');
      rethrow;
    }
  }

  /// Actualizar una relación existente.
  Future<CompanyClient> update({
    required String id,
    String? contractType,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (contractType != null) updates['contract_type'] = contractType;
      if (status != null) updates['status'] = status;

      final data = await _provider.update(id, updates);
      return CompanyClient.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando relación transportista-cliente: $e');
      rethrow;
    }
  }

  /// Eliminar una relación por su ID.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando relación transportista-cliente: $e');
      rethrow;
    }
  }
}
