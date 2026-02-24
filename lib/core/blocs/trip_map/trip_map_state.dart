part of 'trip_map_bloc.dart';

enum TripMapStatus { initial, loading, loaded, failure }

final class TripMapState extends Equatable {
  const TripMapState({
    this.status = TripMapStatus.initial,
    this.trips = const [],
    this.selectedTrip,
    this.tripLogs = const [],
    this.selectedTripLog,
    this.errorMessage = '',
  });

  final TripMapStatus status;
  final List<Trip> trips;
  final Trip? selectedTrip;
  final List<TripLog> tripLogs;
  final TripLog? selectedTripLog;
  final String errorMessage;

  TripMapState copyWith({
    TripMapStatus? status,
    List<Trip>? trips,
    Trip? selectedTrip,
    bool clearSelectedTrip = false,
    List<TripLog>? tripLogs,
    TripLog? selectedTripLog,
    bool clearSelectedTripLog = false,
    String? errorMessage,
  }) {
    return TripMapState(
      status: status ?? this.status,
      trips: trips ?? this.trips,
      selectedTrip: clearSelectedTrip
          ? null
          : (selectedTrip ?? this.selectedTrip),
      tripLogs: tripLogs ?? this.tripLogs,
      selectedTripLog: clearSelectedTripLog
          ? null
          : (selectedTripLog ?? this.selectedTripLog),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    trips,
    selectedTrip,
    tripLogs,
    selectedTripLog,
    errorMessage,
  ];
}
