import 'package:equatable/equatable.dart';

import 'client_company.dart';
import 'client_location.dart';
import 'company.dart';
import 'user.dart';
import 'vehicle.dart';

/// Estado de un viaje.
enum TripStatus {
  pending('pending'),
  inProgress('in_progress'),
  completed('completed'),
  cancelled('cancelled');

  const TripStatus(this.value);
  final String value;

  static TripStatus fromValue(String? value) {
    if (value == null) return TripStatus.pending;
    return TripStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => TripStatus.pending,
    );
  }

  /// Etiqueta legible en español.
  String get label => switch (this) {
    TripStatus.pending => 'Pendiente',
    TripStatus.inProgress => 'En Curso',
    TripStatus.completed => 'Completado',
    TripStatus.cancelled => 'Cancelado',
  };
}

/// Modelo de viaje.
///
/// Corresponde a la tabla `trips` de Supabase.
class Trip extends Equatable {
  const Trip({
    required this.id,
    required this.companyId,
    required this.clientCompanyId,
    required this.vehicleId,
    this.assignedByUserId,
    required this.originLocationId,
    required this.destinationLocationId,
    this.departureTime,
    this.arrivalTime,
    this.status = TripStatus.pending,
    this.price,
    this.createdAt,
    this.company,
    this.clientCompany,
    this.vehicle,
    this.assignedBy,
    this.originLocation,
    this.destinationLocation,
  });

  final String id;
  final String companyId;
  final String clientCompanyId;
  final String vehicleId;
  final String? assignedByUserId;
  final String originLocationId;
  final String destinationLocationId;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final TripStatus status;
  final double? price;
  final DateTime? createdAt;

  /// Relaciones (joins).
  final Company? company;
  final ClientCompany? clientCompany;
  final Vehicle? vehicle;
  final User? assignedBy;
  final ClientLocation? originLocation;
  final ClientLocation? destinationLocation;

  /// Trip vacío.
  static const empty = Trip(
    id: '',
    companyId: '',
    clientCompanyId: '',
    vehicleId: '',
    originLocationId: '',
    destinationLocationId: '',
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Resumen legible del viaje.
  String get displayName {
    final originName = originLocation?.name ?? originLocationId;
    final destName = destinationLocation?.name ?? destinationLocationId;
    return '$originName → $destName';
  }

  /// Crea un [Trip] desde un mapa JSON (respuesta de Supabase).
  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String? ?? '',
      companyId: json['company_id'] as String? ?? '',
      clientCompanyId: json['client_company_id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      assignedByUserId: json['assigned_by_user_id'] as String?,
      originLocationId: json['origin_location_id'] as String? ?? '',
      destinationLocationId: json['destination_location_id'] as String? ?? '',
      departureTime: json['departure_time'] != null
          ? DateTime.tryParse(json['departure_time'] as String)
          : null,
      arrivalTime: json['arrival_time'] != null
          ? DateTime.tryParse(json['arrival_time'] as String)
          : null,
      status: TripStatus.fromValue(json['status'] as String?),
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      company: json['company'] != null && json['company'] is Map
          ? Company.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      clientCompany:
          json['client_company'] != null && json['client_company'] is Map
          ? ClientCompany.fromJson(
              json['client_company'] as Map<String, dynamic>,
            )
          : null,
      vehicle: json['vehicle'] != null && json['vehicle'] is Map
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      assignedBy: json['assigned_by'] != null && json['assigned_by'] is Map
          ? User.fromProfile(json['assigned_by'] as Map<String, dynamic>)
          : null,
      originLocation:
          json['origin_location'] != null && json['origin_location'] is Map
          ? ClientLocation.fromJson(
              json['origin_location'] as Map<String, dynamic>,
            )
          : null,
      destinationLocation:
          json['destination_location'] != null &&
              json['destination_location'] is Map
          ? ClientLocation.fromJson(
              json['destination_location'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  /// No incluye `id`, `created_at` ni las relaciones (son joins).
  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'client_company_id': clientCompanyId,
      'vehicle_id': vehicleId,
      'assigned_by_user_id': assignedByUserId,
      'origin_location_id': originLocationId,
      'destination_location_id': destinationLocationId,
      'departure_time': departureTime?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'status': status.value,
      'price': price,
    };
  }

  Trip copyWith({
    String? id,
    String? companyId,
    String? clientCompanyId,
    String? vehicleId,
    String? assignedByUserId,
    String? originLocationId,
    String? destinationLocationId,
    DateTime? departureTime,
    DateTime? arrivalTime,
    TripStatus? status,
    double? price,
    DateTime? createdAt,
    Company? company,
    ClientCompany? clientCompany,
    Vehicle? vehicle,
    User? assignedBy,
    ClientLocation? originLocation,
    ClientLocation? destinationLocation,
  }) {
    return Trip(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      clientCompanyId: clientCompanyId ?? this.clientCompanyId,
      vehicleId: vehicleId ?? this.vehicleId,
      assignedByUserId: assignedByUserId ?? this.assignedByUserId,
      originLocationId: originLocationId ?? this.originLocationId,
      destinationLocationId:
          destinationLocationId ?? this.destinationLocationId,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      company: company ?? this.company,
      clientCompany: clientCompany ?? this.clientCompany,
      vehicle: vehicle ?? this.vehicle,
      assignedBy: assignedBy ?? this.assignedBy,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
    );
  }

  @override
  List<Object?> get props => [
    id,
    companyId,
    clientCompanyId,
    vehicleId,
    assignedByUserId,
    originLocationId,
    destinationLocationId,
    departureTime,
    arrivalTime,
    status,
    price,
    createdAt,
    company,
    clientCompany,
    vehicle,
    assignedBy,
    originLocation,
    destinationLocation,
  ];
}
