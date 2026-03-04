import 'package:flutter/foundation.dart';

import '../models/finance_category.dart';
import '../providers/finance_category_provider.dart';

/// Repositorio de categorías financieras.
class FinanceCategoryRepository {
  FinanceCategoryRepository({FinanceCategoryProvider? provider})
    : _provider = provider ?? FinanceCategoryProvider();

  final FinanceCategoryProvider _provider;

  /// Obtener todas las categorías de una empresa.
  Future<List<FinanceCategory>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(FinanceCategory.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo categorías financieras: $e');
      rethrow;
    }
  }

  /// Obtener solo categorías activas de una empresa.
  Future<List<FinanceCategory>> getActiveByCompany(String companyId) async {
    try {
      final data = await _provider.getActiveByCompany(companyId);
      return data.map(FinanceCategory.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo categorías activas: $e');
      rethrow;
    }
  }

  /// Crear una nueva categoría.
  Future<FinanceCategory> create({
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
      return FinanceCategory.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando categoría financiera: $e');
      rethrow;
    }
  }

  /// Actualizar una categoría existente.
  Future<FinanceCategory> update({
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
      return FinanceCategory.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando categoría financiera $id: $e');
      rethrow;
    }
  }

  /// Eliminar una categoría.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando categoría financiera $id: $e');
      rethrow;
    }
  }
}
