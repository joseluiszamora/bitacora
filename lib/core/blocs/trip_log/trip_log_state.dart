part of 'trip_log_bloc.dart';

enum TripLogStateStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

final class TripLogState extends Equatable {
  const TripLogState({
    this.status = TripLogStateStatus.initial,
    this.logs = const [],
    this.errorMessage = '',
  });

  final TripLogStateStatus status;
  final List<TripLog> logs;
  final String errorMessage;

  /// Indica si se puede interactuar con la UI.
  bool get isIdle =>
      status == TripLogStateStatus.initial ||
      status == TripLogStateStatus.loaded ||
      status == TripLogStateStatus.success ||
      status == TripLogStateStatus.failure;

  TripLogState copyWith({
    TripLogStateStatus? status,
    List<TripLog>? logs,
    String? errorMessage,
  }) {
    return TripLogState(
      status: status ?? this.status,
      logs: logs ?? this.logs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, logs, errorMessage];
}
