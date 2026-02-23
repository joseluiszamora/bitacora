import 'package:equatable/equatable.dart';

import 'company.dart';

/// Estado del vehículo.
enum VehicleStatus {
  active('active'),
  maintenance('maintenance'),
  inactive('inactive');

  const VehicleStatus(this.value);
  final String value;

  static VehicleStatus fromValue(String? value) {
    if (value == null) return VehicleStatus.active;
    return VehicleStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => VehicleStatus.active,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    VehicleStatus.active => 'Activo',
    VehicleStatus.maintenance => 'En Mantenimiento',
    VehicleStatus.inactive => 'Inactivo',
  };
}

/// Modelo de vehículo.
///
/// Corresponde a la tabla `vehicles` de Supabase.
class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.companyId,
    required this.plateNumber,
    this.brand,
    this.model,
    this.year,
    this.color,
    this.avatarUrl,
    this.chasisCode,
    this.motorCode,
    this.ruatNumber,
    this.soatExpirationDate,
    this.inspectionExpirationDate,
    this.insuranceExpirationDate,
    this.status = VehicleStatus.active,
    this.createdAt,
    this.company,
  });

  final String id;
  final String companyId;
  final String plateNumber;
  final String? brand;
  final String? model;
  final int? year;
  final String? color;
  final String? avatarUrl;
  final String? chasisCode;
  final String? motorCode;
  final String? ruatNumber;
  final DateTime? soatExpirationDate;
  final DateTime? inspectionExpirationDate;
  final DateTime? insuranceExpirationDate;
  final VehicleStatus status;
  final DateTime? createdAt;

  /// Empresa a la que pertenece (join).
  final Company? company;

  /// Vehículo vacío.
  static const empty = Vehicle(id: '', companyId: '', plateNumber: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Nombre descriptivo del vehículo.
  String get displayName {
    final parts = <String>[];
    if (brand != null && brand!.isNotEmpty) parts.add(brand!);
    if (model != null && model!.isNotEmpty) parts.add(model!);
    if (year != null) parts.add('($year)');
    if (parts.isEmpty) return plateNumber;
    return parts.join(' ');
  }

  /// Crea un [Vehicle] desde un mapa JSON (respuesta de Supabase).
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      plateNumber: json['plate_number'] as String? ?? '',
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      chasisCode: json['chasis_code'] as String?,
      motorCode: json['motor_code'] as String?,
      ruatNumber: json['ruat_number'] as String?,
      soatExpirationDate: json['soat_expiration_date'] != null
          ? DateTime.tryParse(json['soat_expiration_date'] as String)
          : null,
      inspectionExpirationDate: json['inspection_expiration_date'] != null
          ? DateTime.tryParse(json['inspection_expiration_date'] as String)
          : null,
      insuranceExpirationDate: json['insurance_expiration_date'] != null
          ? DateTime.tryParse(json['insurance_expiration_date'] as String)
          : null,
      status: VehicleStatus.fromValue(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      company: json['company'] != null && json['company'] is Map
          ? Company.fromJson(json['company'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  /// No incluye `id`, `created_at` ni `company` (es join).
  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'plate_number': plateNumber,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'avatar_url': avatarUrl,
      'chasis_code': chasisCode,
      'motor_code': motorCode,
      'ruat_number': ruatNumber,
      'soat_expiration_date': soatExpirationDate?.toIso8601String(),
      'inspection_expiration_date': inspectionExpirationDate?.toIso8601String(),
      'insurance_expiration_date': insuranceExpirationDate?.toIso8601String(),
      'status': status.value,
    };
  }

  Vehicle copyWith({
    String? id,
    String? companyId,
    String? plateNumber,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? avatarUrl,
    String? chasisCode,
    String? motorCode,
    String? ruatNumber,
    DateTime? soatExpirationDate,
    DateTime? inspectionExpirationDate,
    DateTime? insuranceExpirationDate,
    VehicleStatus? status,
    DateTime? createdAt,
    Company? company,
  }) {
    return Vehicle(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      plateNumber: plateNumber ?? this.plateNumber,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      chasisCode: chasisCode ?? this.chasisCode,
      motorCode: motorCode ?? this.motorCode,
      ruatNumber: ruatNumber ?? this.ruatNumber,
      soatExpirationDate: soatExpirationDate ?? this.soatExpirationDate,
      inspectionExpirationDate:
          inspectionExpirationDate ?? this.inspectionExpirationDate,
      insuranceExpirationDate:
          insuranceExpirationDate ?? this.insuranceExpirationDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      company: company ?? this.company,
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    plateNumber,
    brand,
    model,
    year,
    color,
    avatarUrl,
    chasisCode,
    motorCode,
    ruatNumber,
    soatExpirationDate,
    inspectionExpirationDate,
    insuranceExpirationDate,
    status,
    createdAt,
    company,
  ];
}
