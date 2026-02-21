part of 'client_company_bloc.dart';

sealed class ClientCompanyEvent extends Equatable {
  const ClientCompanyEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar la lista de empresas cliente.
final class ClientCompanyLoadRequested extends ClientCompanyEvent {
  const ClientCompanyLoadRequested();
}

/// Crear una nueva empresa cliente.
final class ClientCompanyCreateRequested extends ClientCompanyEvent {
  const ClientCompanyCreateRequested({
    required this.name,
    this.nit,
    this.address,
    this.contactEmail,
  });

  final String name;
  final String? nit;
  final String? address;
  final String? contactEmail;

  @override
  List<Object?> get props => [name, nit, address, contactEmail];
}

/// Actualizar una empresa cliente existente.
final class ClientCompanyUpdateRequested extends ClientCompanyEvent {
  const ClientCompanyUpdateRequested({
    required this.id,
    this.name,
    this.nit,
    this.address,
    this.contactEmail,
  });

  final String id;
  final String? name;
  final String? nit;
  final String? address;
  final String? contactEmail;

  @override
  List<Object?> get props => [id, name, nit, address, contactEmail];
}

/// Eliminar una empresa cliente.
final class ClientCompanyDeleteRequested extends ClientCompanyEvent {
  const ClientCompanyDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
