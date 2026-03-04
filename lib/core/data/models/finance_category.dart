import 'package:equatable/equatable.dart';

/// Modelo de categoría de movimiento financiero.
///
/// Ejemplos: "Pago por viaje", "Pago de impuestos",
/// "Reparación de motor", "Cambio de llantas".
/// Corresponde a la tabla `finance_categories` de Supabase.
class FinanceCategory extends Equatable {
  const FinanceCategory({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String companyId;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;

  static const empty = FinanceCategory(id: '', companyId: '', name: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  factory FinanceCategory.fromJson(Map<String, dynamic> json) {
    return FinanceCategory(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  FinanceCategory copyWith({
    String? id,
    String? companyId,
    String? name,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FinanceCategory(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    description,
    isActive,
    createdAt,
  ];
}
