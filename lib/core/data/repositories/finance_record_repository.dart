import 'package:flutter/foundation.dart';

import '../models/finance_record.dart';
import '../providers/finance_record_provider.dart';

/// Repositorio de registros/movimientos financieros.
class FinanceRecordRepository {
  FinanceRecordRepository({FinanceRecordProvider? provider})
    : _provider = provider ?? FinanceRecordProvider();

  final FinanceRecordProvider _provider;

  /// Obtener todos los registros de una empresa.
  Future<List<FinanceRecord>> getByCompany(String companyId) async {
    try {
      final data = await _provider.getByCompany(companyId);
      return data.map(FinanceRecord.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo registros financieros: $e');
      rethrow;
    }
  }

  /// Obtener registros por grupo.
  Future<List<FinanceRecord>> getByGroup(String groupId) async {
    try {
      final data = await _provider.getByGroup(groupId);
      return data.map(FinanceRecord.fromJson).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo registros del grupo: $e');
      rethrow;
    }
  }

  /// Crear un nuevo registro.
  Future<FinanceRecord> create({
    required String companyId,
    required String groupId,
    required String categoryId,
    required FinanceRecordType type,
    required double amount,
    String? responsibleUserId,
    String? description,
    DateTime? recordDate,
  }) async {
    try {
      final data = await _provider.create({
        'company_id': companyId,
        'group_id': groupId,
        'category_id': categoryId,
        'type': type.value,
        'amount': amount,
        // ignore: use_null_aware_elements
        if (responsibleUserId != null) 'responsible_user_id': responsibleUserId,
        'description': description,
        'record_date': (recordDate ?? DateTime.now()).toIso8601String(),
      });
      return FinanceRecord.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error creando registro financiero: $e');
      rethrow;
    }
  }

  /// Actualizar un registro existente.
  Future<FinanceRecord> update({
    required String id,
    String? groupId,
    String? categoryId,
    FinanceRecordType? type,
    double? amount,
    String? responsibleUserId,
    String? description,
    DateTime? recordDate,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (groupId != null) updates['group_id'] = groupId;
      if (categoryId != null) updates['category_id'] = categoryId;
      if (type != null) updates['type'] = type.value;
      if (amount != null) updates['amount'] = amount;
      if (responsibleUserId != null) {
        updates['responsible_user_id'] = responsibleUserId;
      }
      if (description != null) updates['description'] = description;
      if (recordDate != null) {
        updates['record_date'] = recordDate.toIso8601String();
      }

      final data = await _provider.update(id, updates);
      return FinanceRecord.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error actualizando registro financiero $id: $e');
      rethrow;
    }
  }

  /// Eliminar un registro.
  Future<void> delete(String id) async {
    try {
      await _provider.delete(id);
    } catch (e) {
      debugPrint('❌ Error eliminando registro financiero $id: $e');
      rethrow;
    }
  }
}
