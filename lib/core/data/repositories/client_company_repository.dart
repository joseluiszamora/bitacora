import 'package:flutter/foundation.dart';

import '../models/client_company.dart';
import '../providers/client_company_provider.dart';

/// Repositorio de empresas cliente.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class ClientCompanyRepository {
  ClientCompanyRepository({ClientCompanyProvider? provider})
    : _provider = provider ?? ClientCompanyProvider();

  final ClientCompanyProvider _provider;

  /// Obtener todas las empresas cliente.
  Future<List<ClientCompany>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(ClientCompany.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo empresas cliente: $e');
      rethrow;
    }
  }

  /// Obtener una empresa cliente por su ID.
  Future<ClientCompany?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return ClientCompany.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo empresa cliente $id: $e');
      rethrow;
    }
  }

  /// Crear una nueva empresa cliente.
  Future<ClientCompany> create({
    required String name,
    String? nit,
    String? address,
    String? contactEmail,
  }) async {
    try {
      final data = await _provider.create({
        'name': name,
        'nit': nit,
        'address': address,
        'contact_email': contactEmail,
      });
      return ClientCompany.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando empresa cliente: $e');
      rethrow;
    }
  }

  /// Actualizar una empresa cliente existente.
  Future<ClientCompany> update({
    required String id,
    String? name,
    String? nit,
    String? address,
    String? contactEmail,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (nit != null) updates['nit'] = nit;
      if (address != null) updates['address'] = address;
      if (contactEmail != null) updates['contact_email'] = contactEmail;

      final data = await _provider.update(id, updates);
      return ClientCompany.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando empresa cliente: $e');
      rethrow;
    }
  }

  /// Eliminar una empresa cliente por su ID.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando empresa cliente: $e');
      rethrow;
    }
  }
}
