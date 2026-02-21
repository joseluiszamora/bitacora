part of 'client_company_bloc.dart';

enum ClientCompanyStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

final class ClientCompanyState extends Equatable {
  const ClientCompanyState({
    this.status = ClientCompanyStatus.initial,
    this.clientCompanies = const [],
    this.errorMessage = '',
  });

  final ClientCompanyStatus status;
  final List<ClientCompany> clientCompanies;
  final String errorMessage;

  /// Indica si se puede interactuar con la UI (no está en operación).
  bool get isIdle =>
      status == ClientCompanyStatus.initial ||
      status == ClientCompanyStatus.loaded ||
      status == ClientCompanyStatus.success ||
      status == ClientCompanyStatus.failure;

  ClientCompanyState copyWith({
    ClientCompanyStatus? status,
    List<ClientCompany>? clientCompanies,
    String? errorMessage,
  }) {
    return ClientCompanyState(
      status: status ?? this.status,
      clientCompanies: clientCompanies ?? this.clientCompanies,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, clientCompanies, errorMessage];
}
