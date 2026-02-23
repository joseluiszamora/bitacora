part of 'client_location_bloc.dart';

/// Estados posibles del BLoC de ubicaciones.
enum ClientLocationBlocStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

/// Estado del BLoC de ubicaciones de clientes.
final class ClientLocationState extends Equatable {
  const ClientLocationState({
    this.status = ClientLocationBlocStatus.initial,
    this.locations = const [],
    this.errorMessage = '',
  });

  final ClientLocationBlocStatus status;
  final List<ClientLocation> locations;
  final String errorMessage;

  /// Indica si el BLoC está procesando una operación.
  bool get isIdle =>
      status != ClientLocationBlocStatus.loading &&
      status != ClientLocationBlocStatus.creating &&
      status != ClientLocationBlocStatus.updating &&
      status != ClientLocationBlocStatus.deleting;

  ClientLocationState copyWith({
    ClientLocationBlocStatus? status,
    List<ClientLocation>? locations,
    String? errorMessage,
  }) {
    return ClientLocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, locations, errorMessage];
}
