import 'package:equatable/equatable.dart';

/// Tipo de documento de vehículo.
enum VehicleDocumentType {
  soat('soat'),
  inspection('inspection'),
  insurance('insurance'),
  ruat('ruat');

  const VehicleDocumentType(this.value);
  final String value;

  static VehicleDocumentType fromValue(String? value) {
    if (value == null) return VehicleDocumentType.soat;
    return VehicleDocumentType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => VehicleDocumentType.soat,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    VehicleDocumentType.soat => 'SOAT',
    VehicleDocumentType.inspection => 'Inspección Técnica',
    VehicleDocumentType.insurance => 'Seguro',
    VehicleDocumentType.ruat => 'RUAT',
  };
}

/// Modelo de documento de vehículo.
///
/// Corresponde a la tabla `vehicle_documents` de Supabase.
class VehicleDocument extends Equatable {
  const VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.type,
    this.fileUrl,
    this.expirationDate,
    this.createdAt,
  });

  final String id;
  final String vehicleId;
  final VehicleDocumentType type;
  final String? fileUrl;
  final DateTime? expirationDate;
  final DateTime? createdAt;

  /// Documento vacío.
  static const empty = VehicleDocument(
    id: '',
    vehicleId: '',
    type: VehicleDocumentType.soat,
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Indica si el documento está vencido.
  bool get isExpired {
    if (expirationDate == null) return false;
    return expirationDate!.isBefore(DateTime.now());
  }

  /// Indica si el documento vence dentro de los próximos 30 días.
  bool get isExpiringSoon {
    if (expirationDate == null) return false;
    final thirtyDaysFromNow = DateTime.now().add(const Duration(days: 30));
    return expirationDate!.isBefore(thirtyDaysFromNow) && !isExpired;
  }

  /// Crea un [VehicleDocument] desde un mapa JSON.
  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      type: VehicleDocumentType.fromValue(json['type'] as String?),
      fileUrl: json['file_url'] as String?,
      expirationDate: json['expiration_date'] != null
          ? DateTime.tryParse(json['expiration_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'type': type.value,
      'file_url': fileUrl,
      'expiration_date': expirationDate?.toIso8601String(),
    };
  }

  VehicleDocument copyWith({
    String? id,
    String? vehicleId,
    VehicleDocumentType? type,
    String? fileUrl,
    DateTime? expirationDate,
    DateTime? createdAt,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    type,
    fileUrl,
    expirationDate,
    createdAt,
  ];
}
