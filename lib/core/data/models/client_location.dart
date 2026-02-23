import 'package:equatable/equatable.dart';

import 'city.dart';
import 'client_company.dart';

/// Tipo de ubicación del cliente.
enum ClientLocationType {
  warehouse('WAREHOUSE'),
  distributionCenter('DISTRIBUTION_CENTER'),
  office('OFFICE'),
  plant('PLANT');

  const ClientLocationType(this.value);
  final String value;

  static ClientLocationType fromValue(String? value) {
    if (value == null) return ClientLocationType.warehouse;
    return ClientLocationType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ClientLocationType.warehouse,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    ClientLocationType.warehouse => 'Almacén',
    ClientLocationType.distributionCenter => 'Centro de Distribución',
    ClientLocationType.office => 'Oficina',
    ClientLocationType.plant => 'Planta',
  };
}

/// Estado de la ubicación.
enum ClientLocationStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  const ClientLocationStatus(this.value);
  final String value;

  static ClientLocationStatus fromValue(String? value) {
    if (value == null) return ClientLocationStatus.active;
    return ClientLocationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ClientLocationStatus.active,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    ClientLocationStatus.active => 'Activa',
    ClientLocationStatus.inactive => 'Inactiva',
  };
}

/// Modelo de ubicación de empresa cliente.
///
/// Corresponde a la tabla `client_locations` de Supabase.
/// Cada empresa cliente puede tener N ubicaciones (almacenes, plantas, etc.).
class ClientLocation extends Equatable {
  const ClientLocation({
    required this.id,
    required this.clientCompanyId,
    required this.name,
    this.type = ClientLocationType.warehouse,
    this.address,
    this.cityId,
    this.country = 'Bolivia',
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.status = ClientLocationStatus.active,
    this.createdAt,
    this.clientCompany,
    this.city,
  });

  final String id;
  final String clientCompanyId;
  final String name;
  final ClientLocationType type;
  final String? address;
  final String? cityId;
  final String country;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final ClientLocationStatus status;
  final DateTime? createdAt;

  /// Relaciones (joins).
  final ClientCompany? clientCompany;
  final City? city;

  /// Ubicación vacía.
  static const empty = ClientLocation(id: '', clientCompanyId: '', name: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Nombre legible de la ubicación.
  String get displayName {
    final typeName = type.label;
    return '$name ($typeName)';
  }

  /// Crea un [ClientLocation] desde un mapa JSON (respuesta de Supabase).
  factory ClientLocation.fromJson(Map<String, dynamic> json) {
    return ClientLocation(
      id: json['id'] as String? ?? '',
      clientCompanyId: json['client_company_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: ClientLocationType.fromValue(json['type'] as String?),
      address: json['address'] as String?,
      cityId: json['city_id'] as String?,
      country: json['country'] as String? ?? 'Bolivia',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      status: ClientLocationStatus.fromValue(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      clientCompany:
          json['client_company'] != null && json['client_company'] is Map
          ? ClientCompany.fromJson(
              json['client_company'] as Map<String, dynamic>,
            )
          : null,
      city: json['city'] != null && json['city'] is Map
          ? City.fromJson(json['city'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'client_company_id': clientCompanyId,
      'name': name,
      'type': type.value,
      'address': address,
      'city_id': cityId,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'status': status.value,
    };
  }

  ClientLocation copyWith({
    String? id,
    String? clientCompanyId,
    String? name,
    ClientLocationType? type,
    String? address,
    String? cityId,
    String? country,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    ClientLocationStatus? status,
    DateTime? createdAt,
    ClientCompany? clientCompany,
    City? city,
  }) {
    return ClientLocation(
      id: id ?? this.id,
      clientCompanyId: clientCompanyId ?? this.clientCompanyId,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      clientCompany: clientCompany ?? this.clientCompany,
      city: city ?? this.city,
    );
  }

  @override
  List<Object?> get props => [
    id,
    clientCompanyId,
    name,
    type,
    address,
    cityId,
    country,
    latitude,
    longitude,
    contactName,
    contactPhone,
    status,
    createdAt,
    clientCompany,
    city,
  ];
}
