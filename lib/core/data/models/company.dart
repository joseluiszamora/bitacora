import 'package:equatable/equatable.dart';

/// Modelo de empresa/compañía.
///
/// Corresponde a la tabla `companies` de Supabase.
class Company extends Equatable {
  const Company({
    required this.id,
    required this.name,
    this.socialReason,
    this.nit,
    this.status = 'active',
    this.createdAt,
  });

  final String id;
  final String name;
  final String? socialReason;
  final String? nit;
  final String status;
  final DateTime? createdAt;

  /// Empresa vacía (usuario sin empresa asignada).
  static const empty = Company(id: '', name: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Crea una [Company] desde un mapa JSON (respuesta de Supabase).
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      socialReason: json['social_reason'] as String?,
      nit: json['nit'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'social_reason': socialReason,
      'nit': nit,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  Company copyWith({
    String? id,
    String? name,
    String? socialReason,
    String? nit,
    String? status,
    DateTime? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      socialReason: socialReason ?? this.socialReason,
      nit: nit ?? this.nit,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, socialReason, nit, status, createdAt];
}
