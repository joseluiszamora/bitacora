part of 'trip_bloc.dart';

enum TripStateStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

final class TripState extends Equatable {
  const TripState({
    this.status = TripStateStatus.initial,
    this.trips = const [],
    this.errorMessage = '',
  });

  final TripStateStatus status;
  final List<Trip> trips;
  final String errorMessage;

  /// Indica si se puede interactuar con la UI.
  bool get isIdle =>
      status == TripStateStatus.initial ||
      status == TripStateStatus.loaded ||
      status == TripStateStatus.success ||
      status == TripStateStatus.failure;

  TripState copyWith({
    TripStateStatus? status,
    List<Trip>? trips,
    String? errorMessage,
  }) {
    return TripState(
      status: status ?? this.status,
      trips: trips ?? this.trips,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trips, errorMessage];
}
