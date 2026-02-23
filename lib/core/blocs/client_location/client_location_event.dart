part of 'client_location_bloc.dart';

sealed class ClientLocationEvent extends Equatable {
  const ClientLocationEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar ubicaciones. Opcionalmente filtra por clientCompanyId.
final class ClientLocationLoadRequested extends ClientLocationEvent {
  const ClientLocationLoadRequested({this.clientCompanyId});

  final String? clientCompanyId;

  @override
  List<Object?> get props => [clientCompanyId];
}

/// Crear una nueva ubicación.
final class ClientLocationCreateRequested extends ClientLocationEvent {
  const ClientLocationCreateRequested({
    required this.clientCompanyId,
    required this.name,
    required this.type,
    this.address,
    this.cityId,
    this.country = 'Bolivia',
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
  });

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

  @override
  List<Object?> get props => [
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
  ];
}

/// Actualizar una ubicación existente.
final class ClientLocationUpdateRequested extends ClientLocationEvent {
  const ClientLocationUpdateRequested({
    required this.id,
    this.clientCompanyId,
    this.name,
    this.type,
    this.address,
    this.cityId,
    this.country,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.status,
  });

  final String id;
  final String? clientCompanyId;
  final String? name;
  final ClientLocationType? type;
  final String? address;
  final String? cityId;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final ClientLocationStatus? status;

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
  ];
}

/// Eliminar una ubicación.
final class ClientLocationDeleteRequested extends ClientLocationEvent {
  const ClientLocationDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
