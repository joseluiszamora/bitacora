part of 'trip_map_bloc.dart';

enum TripMapStatus { initial, loading, loaded, failure }

final class TripMapState extends Equatable {
  const TripMapState({
    this.status = TripMapStatus.initial,
    this.trips = const [],
    this.selectedTrip,
    this.errorMessage = '',
  });

  final TripMapStatus status;
  final List<Trip> trips;
  final Trip? selectedTrip;
  final String errorMessage;

  TripMapState copyWith({
    TripMapStatus? status,
    List<Trip>? trips,
    Trip? selectedTrip,
    bool clearSelectedTrip = false,
    String? errorMessage,
  }) {
    return TripMapState(
      status: status ?? this.status,
      trips: trips ?? this.trips,
      selectedTrip: clearSelectedTrip
          ? null
          : (selectedTrip ?? this.selectedTrip),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trips, selectedTrip, errorMessage];
}
