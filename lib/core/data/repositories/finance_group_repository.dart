import 'package:flutter/foundation.dart';

import '../models/finance_group.dart';
import '../providers/finance_group_provider.dart';

/// Repositorio de grupos financieros.
class FinanceGroupRepository {
  FinanceGroupRepository({FinanceGroupProvider? provider})
    : _provider = provider ?? FinanceGroupProvider();

  final FinanceGroupProvider _provider;

  /// Obtener todos los grupos de una empresa.
  Future<List<FinanceGroup>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(FinanceGroup.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo grupos financieros: $e');
      rethrow;
    }
  }

  /// Obtener solo grupos activos de una empresa.
  Future<List<FinanceGroup>> getActiveByCompany(String companyId) async {
    try {
      final data = await _provider.getActiveByCompany(companyId);
      return data.map(FinanceGroup.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo grupos activos: $e');
      rethrow;
    }
  }

  /// Crear un nuevo grupo.
  Future<FinanceGroup> create({
    required String companyId,
    required String name,
    String? description,
  }) async {
    try {
      final data = await _provider.create({
        'company_id': companyId,
        'name': name,
        'description': description,
        'is_active': true,
      });
      return FinanceGroup.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando grupo financiero: $e');
      rethrow;
    }
  }

  /// Actualizar un grupo existente.
  Future<FinanceGroup> update({
    required String id,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (isActive != null) updates['is_active'] = isActive;

      final data = await _provider.update(id, updates);
      return FinanceGroup.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando grupo financiero $id: $e');
      rethrow;
    }
  }

  /// Eliminar un grupo.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando grupo financiero $id: $e');
      rethrow;
    }
  }
}
