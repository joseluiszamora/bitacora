part of 'company_bloc.dart';

enum CompanyStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

final class CompanyState extends Equatable {
  const CompanyState({
    this.status = CompanyStatus.initial,
    this.companies = const [],
    this.errorMessage = '',
  });

  final CompanyStatus status;
  final List<Company> companies;
  final String errorMessage;

  /// Indica si se puede interactuar con la UI (no está en operación).
  bool get isIdle =>
      status == CompanyStatus.initial ||
      status == CompanyStatus.loaded ||
      status == CompanyStatus.success ||
      status == CompanyStatus.failure;

  CompanyState copyWith({
    CompanyStatus? status,
    List<Company>? companies,
    String? errorMessage,
  }) {
    return CompanyState(
      status: status ?? this.status,
      companies: companies ?? this.companies,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, companies, errorMessage];
}
