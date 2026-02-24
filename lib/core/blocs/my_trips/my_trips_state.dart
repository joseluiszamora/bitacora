part of 'my_trips_bloc.dart';

enum MyTripsStatus { initial, loading, loaded, failure }

final class MyTripsState extends Equatable {
  const MyTripsState({
    this.status = MyTripsStatus.initial,
    this.trips = const [],
    this.errorMessage = '',
  });

  final MyTripsStatus status;
  final List<Trip> trips;
  final String errorMessage;

  MyTripsState copyWith({
    MyTripsStatus? status,
    List<Trip>? trips,
    String? errorMessage,
  }) {
    return MyTripsState(
      status: status ?? this.status,
      trips: trips ?? this.trips,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trips, errorMessage];
}
