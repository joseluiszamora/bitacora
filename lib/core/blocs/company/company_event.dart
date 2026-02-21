part of 'company_bloc.dart';

sealed class CompanyEvent extends Equatable {
  const CompanyEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar la lista de compañías.
final class CompanyLoadRequested extends CompanyEvent {
  const CompanyLoadRequested();
}

/// Crear una nueva compañía.
final class CompanyCreateRequested extends CompanyEvent {
  const CompanyCreateRequested({
    required this.name,
    this.socialReason,
    this.nit,
  });

  final String name;
  final String? socialReason;
  final String? nit;

  @override
  List<Object?> get props => [name, socialReason, nit];
}

/// Actualizar una compañía existente.
final class CompanyUpdateRequested extends CompanyEvent {
  const CompanyUpdateRequested({
    required this.id,
    this.name,
    this.socialReason,
    this.nit,
    this.status,
  });

  final String id;
  final String? name;
  final String? socialReason;
  final String? nit;
  final String? status;

  @override
  List<Object?> get props => [id, name, socialReason, nit, status];
}

/// Eliminar una compañía.
final class CompanyDeleteRequested extends CompanyEvent {
  const CompanyDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
