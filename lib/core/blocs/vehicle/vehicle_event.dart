part of 'vehicle_bloc.dart';

sealed class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar la lista de vehículos.
/// Si [companyId] es null, carga todos (super_admin).
/// Si tiene valor, filtra por empresa (admin).
final class VehicleLoadRequested extends VehicleEvent {
  const VehicleLoadRequested({this.companyId});

  final String? companyId;

  @override
  List<Object?> get props => [companyId];
}

/// Crear un nuevo vehículo.
final class VehicleCreateRequested extends VehicleEvent {
  const VehicleCreateRequested({
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
  });

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

  @override
  List<Object?> get props => [
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
  ];
}

/// Actualizar un vehículo existente.
final class VehicleUpdateRequested extends VehicleEvent {
  const VehicleUpdateRequested({
    required this.id,
    this.companyId,
    this.plateNumber,
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
    this.status,
  });

  final String id;
  final String? companyId;
  final String? plateNumber;
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
  final VehicleStatus? status;

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
  ];
}

/// Eliminar un vehículo.
final class VehicleDeleteRequested extends VehicleEvent {
  const VehicleDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
