import 'package:flutter/foundation.dart';

import '../models/company.dart';
import '../providers/company_provider.dart';

/// Repositorio de compañías.
///
/// Encapsula la lógica de negocio y transforma los datos
/// del provider en modelos tipados.
class CompanyRepository {
  CompanyRepository({CompanyProvider? provider})
    : _provider = provider ?? CompanyProvider();

  final CompanyProvider _provider;

  /// Obtener todas las compañías.
  Future<List<Company>> getAll() async {
    try {
      final data = await _provider.getAll();
      return data.map(Company.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo compañías: $e');
      rethrow;
    }
  }

  /// Obtener una compañía por su ID.
  Future<Company?> getById(String id) async {
    try {
      final data = await _provider.getById(id);
      if (data == null) return null;
      return Company.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error obteniendo compañía $id: $e');
      rethrow;
    }
  }

  /// Crear una nueva compañía.
  Future<Company> create({
    required String name,
    String? socialReason,
    String? nit,
  }) async {
    try {
      final data = await _provider.create({
        'name': name,
        'social_reason': socialReason,
        'nit': nit,
        'status': 'active',
      });
      return Company.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando compañía: $e');
      rethrow;
    }
  }

  /// Actualizar una compañía existente.
  Future<Company> update({
    required String id,
    String? name,
    String? socialReason,
    String? nit,
    String? status,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (socialReason != null) updates['social_reason'] = socialReason;
      if (nit != null) updates['nit'] = nit;
      if (status != null) updates['status'] = status;

      final data = await _provider.update(id, updates);
      return Company.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando compañía $id: $e');
      rethrow;
    }
  }

  /// Eliminar una compañía.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando compañía $id: $e');
      rethrow;
    }
  }
}
