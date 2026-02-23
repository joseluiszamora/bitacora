import 'package:equatable/equatable.dart';

import 'user.dart';
import 'vehicle.dart';

/// Modelo de asignación vehículo-conductor.
///
/// Corresponde a la tabla `vehicle_assignments` de Supabase.
/// Representa la relación muchos-a-muchos entre vehículos y conductores.
class VehicleAssignment extends Equatable {
  const VehicleAssignment({
    required this.id,
    required this.vehicleId,
    required this.driverId,
    this.assignedByUserId,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.createdAt,
    this.vehicle,
    this.driver,
    this.assignedBy,
  });

  final String id;
  final String vehicleId;
  final String driverId;
  final String? assignedByUserId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime? createdAt;

  /// Relaciones (joins).
  final Vehicle? vehicle;
  final User? driver;
  final User? assignedBy;

  /// Asignación vacía.
  static final empty = VehicleAssignment(
    id: '',
    vehicleId: '',
    driverId: '',
    startDate: DateTime(2000),
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  /// Resumen legible de la asignación.
  String get displayName {
    final vehicleName = vehicle?.displayName ?? vehicleId;
    final driverName = driver?.name ?? driverId;
    return '$driverName → $vehicleName';
  }

  /// Crea un [VehicleAssignment] desde un mapa JSON (respuesta de Supabase).
  factory VehicleAssignment.fromJson(Map<String, dynamic> json) {
    return VehicleAssignment(
      id: json['id'] as String? ?? '',
      vehicleId: json['vehicle_id'] as String? ?? '',
      driverId: json['driver_id'] as String? ?? '',
      assignedByUserId: json['assigned_by_user_id'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      vehicle: json['vehicle'] != null && json['vehicle'] is Map
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      driver: json['driver'] != null && json['driver'] is Map
          ? User.fromProfile(json['driver'] as Map<String, dynamic>)
          : null,
      assignedBy: json['assigned_by'] != null && json['assigned_by'] is Map
          ? User.fromProfile(json['assigned_by'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Serializa a JSON para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'assigned_by_user_id': assignedByUserId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  VehicleAssignment copyWith({
    String? id,
    String? vehicleId,
    String? driverId,
    String? assignedByUserId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    Vehicle? vehicle,
    User? driver,
    User? assignedBy,
  }) {
    return VehicleAssignment(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      assignedByUserId: assignedByUserId ?? this.assignedByUserId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      vehicle: vehicle ?? this.vehicle,
      driver: driver ?? this.driver,
      assignedBy: assignedBy ?? this.assignedBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    vehicleId,
    driverId,
    assignedByUserId,
    startDate,
    endDate,
    isActive,
    createdAt,
    vehicle,
    driver,
    assignedBy,
  ];
}
