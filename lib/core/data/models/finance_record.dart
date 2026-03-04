import 'package:equatable/equatable.dart';

import 'finance_category.dart';
import 'finance_group.dart';

/// Tipo de movimiento financiero.
enum FinanceRecordType {
  income('INCOME'),
  expense('EXPENSE');

  const FinanceRecordType(this.value);
  final String value;

  String get label => switch (this) {
    FinanceRecordType.income => 'Ingreso',
    FinanceRecordType.expense => 'Egreso',
  };

  String get icon => switch (this) {
    FinanceRecordType.income => '📈',
    FinanceRecordType.expense => '📉',
  };

  static FinanceRecordType fromValue(String value) {
    return FinanceRecordType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FinanceRecordType.expense,
    );
  }
}

/// Modelo de registro/movimiento financiero.
///
/// Representa un ingreso o egreso dentro de un grupo y categoría.
/// Corresponde a la tabla `finance_records` de Supabase.
class FinanceRecord extends Equatable {
  const FinanceRecord({
    required this.id,
    required this.companyId,
    required this.groupId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.responsibleUserId,
    this.description,
    this.recordDate,
    this.createdAt,
    this.group,
    this.category,
    this.responsibleUserName,
  });

  final String id;
  final String companyId;
  final String groupId;
  final String categoryId;
  final FinanceRecordType type;
  final double amount;
  final String? responsibleUserId;
  final String? description;
  final DateTime? recordDate;
  final DateTime? createdAt;

  /// Joins opcionales.
  final FinanceGroup? group;
  final FinanceCategory? category;
  final String? responsibleUserName;

  static final empty = FinanceRecord(
    id: '',
    companyId: '',
    groupId: '',
    categoryId: '',
    type: FinanceRecordType.expense,
    amount: 0,
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  bool get isIncome => type == FinanceRecordType.income;
  bool get isExpense => type == FinanceRecordType.expense;

  /// Indica si el movimiento tiene un responsable asignado.
  bool get hasResponsible =>
      responsibleUserId != null && responsibleUserId!.isNotEmpty;

  /// Nombre para mostrar: "📈 Ingreso — Bs. 1,500.00" o "📉 Egreso — Bs. 200.00".
  String get displayName {
    final formattedAmount = amount.toStringAsFixed(2);
    return '${type.icon} ${type.label} — Bs. $formattedAmount';
  }

  factory FinanceRecord.fromJson(Map<String, dynamic> json) {
    // Parsear joins opcionales.
    FinanceGroup? group;
    if (json['finance_groups'] is Map<String, dynamic>) {
      group = FinanceGroup.fromJson(
        json['finance_groups'] as Map<String, dynamic>,
      );
    }

    FinanceCategory? category;
    if (json['finance_categories'] is Map<String, dynamic>) {
      category = FinanceCategory.fromJson(
        json['finance_categories'] as Map<String, dynamic>,
      );
    }

    // Join del responsable (profiles).
    String? responsibleUserName;
    if (json['responsible_user'] is Map<String, dynamic>) {
      final profile = json['responsible_user'] as Map<String, dynamic>;
      responsibleUserName = profile['full_name'] as String?;
    }

    return FinanceRecord(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      type: FinanceRecordType.fromValue(json['type'] as String? ?? 'EXPENSE'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      responsibleUserId: json['responsible_user_id'] as String?,
      description: json['description'] as String?,
      recordDate: json['record_date'] != null
          ? DateTime.tryParse(json['record_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      group: group,
      category: category,
      responsibleUserName: responsibleUserName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'group_id': groupId,
      'category_id': categoryId,
      'type': type.value,
      'amount': amount,
      'responsible_user_id': responsibleUserId,
      'description': description,
      'record_date': recordDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  FinanceRecord copyWith({
    String? id,
    String? companyId,
    String? groupId,
    String? categoryId,
    FinanceRecordType? type,
    double? amount,
    String? responsibleUserId,
    String? description,
    DateTime? recordDate,
    DateTime? createdAt,
    FinanceGroup? group,
    FinanceCategory? category,
    String? responsibleUserName,
  }) {
    return FinanceRecord(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      groupId: groupId ?? this.groupId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      responsibleUserId: responsibleUserId ?? this.responsibleUserId,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      group: group ?? this.group,
      category: category ?? this.category,
      responsibleUserName: responsibleUserName ?? this.responsibleUserName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    groupId,
    categoryId,
    type,
    amount,
    responsibleUserId,
    description,
    recordDate,
    createdAt,
    group,
    category,
    responsibleUserName,
  ];
}
