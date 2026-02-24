import 'package:bitacora/core/blocs/trip_map/trip_map_bloc.dart';
import 'package:bitacora/core/data/models/trip.dart';
import 'package:bitacora/core/data/repositories/trip_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}

void main() {
  late MockTripRepository mockRepository;

  final sampleTrips = [
    Trip(
      id: 'trip-1',
      companyId: 'comp-1',
      vehicleId: 'veh-1',
      clientCompanyId: 'cc-1',
      originLocationId: 'loc-1',
      destinationLocationId: 'loc-2',
      status: TripStatus.pending,
    ),
    Trip(
      id: 'trip-2',
      companyId: 'comp-1',
      vehicleId: 'veh-2',
      clientCompanyId: 'cc-1',
      originLocationId: 'loc-3',
      destinationLocationId: 'loc-4',
      status: TripStatus.inProgress,
    ),
  ];

  setUp(() {
    mockRepository = MockTripRepository();
  });

  group('TripMapBloc', () {
    test('initial state is correct', () {
      final bloc = TripMapBloc(tripRepository: mockRepository);
      expect(bloc.state, const TripMapState());
      expect(bloc.state.status, TripMapStatus.initial);
      expect(bloc.state.trips, isEmpty);
      expect(bloc.state.selectedTrip, isNull);
      expect(bloc.state.errorMessage, isEmpty);
      bloc.close();
    });

    group('TripMapLoadRequested', () {
      blocTest<TripMapBloc, TripMapState>(
        'emits [loading, loaded] with getByCompany when companyId is provided',
        setUp: () {
          when(
            () => mockRepository.getByCompany('comp-1'),
          ).thenAnswer((_) async => sampleTrips);
        },
        build: () => TripMapBloc(tripRepository: mockRepository),
        act: (bloc) =>
            bloc.add(const TripMapLoadRequested(companyId: 'comp-1')),
        expect: () => [
          const TripMapState(status: TripMapStatus.loading),
          TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        ],
        verify: (_) {
          verify(() => mockRepository.getByCompany('comp-1')).called(1);
          verifyNever(() => mockRepository.getAll());
        },
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits [loading, loaded] with getAll when companyId is empty',
        setUp: () {
          when(
            () => mockRepository.getAll(),
          ).thenAnswer((_) async => sampleTrips);
        },
        build: () => TripMapBloc(tripRepository: mockRepository),
        act: (bloc) => bloc.add(const TripMapLoadRequested(companyId: '')),
        expect: () => [
          const TripMapState(status: TripMapStatus.loading),
          TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        ],
        verify: (_) {
          verify(() => mockRepository.getAll()).called(1);
          verifyNever(() => mockRepository.getByCompany(any()));
        },
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits [loading, failure] on error',
        setUp: () {
          when(
            () => mockRepository.getByCompany('comp-1'),
          ).thenThrow(Exception('Network error'));
        },
        build: () => TripMapBloc(tripRepository: mockRepository),
        act: (bloc) =>
            bloc.add(const TripMapLoadRequested(companyId: 'comp-1')),
        expect: () => [
          const TripMapState(status: TripMapStatus.loading),
          isA<TripMapState>()
              .having((s) => s.status, 'status', TripMapStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Network error'),
              ),
        ],
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits loaded with empty list when no trips found',
        setUp: () {
          when(
            () => mockRepository.getByCompany('comp-1'),
          ).thenAnswer((_) async => []);
        },
        build: () => TripMapBloc(tripRepository: mockRepository),
        act: (bloc) =>
            bloc.add(const TripMapLoadRequested(companyId: 'comp-1')),
        expect: () => [
          const TripMapState(status: TripMapStatus.loading),
          const TripMapState(status: TripMapStatus.loaded, trips: []),
        ],
      );
    });

    group('TripMapTripSelected', () {
      blocTest<TripMapBloc, TripMapState>(
        'emits state with selected trip',
        seed: () =>
            TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        build: () => TripMapBloc(tripRepository: mockRepository),
        act: (bloc) => bloc.add(TripMapTripSelected(trip: sampleTrips.first)),
        expect: () => [
          TripMapState(
            status: TripMapStatus.loaded,
            trips: sampleTrips,
            selectedTrip: sampleTrips.first,
          ),
        ],
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits state with null trip when cleared',
        seed: () => TripMapState(
          status: TripMapStatus.loaded,
          trips: sampleTrips,
          selectedTrip: sampleTrips.first,
        ),
        build: () => TripMapBloc(tripRepository: mockRepository),
        act: (bloc) => bloc.add(const TripMapTripSelected()),
        expect: () => [
          TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        ],
      );
    });
  });

  group('TripMapEvent', () {
    test('TripMapLoadRequested supports value equality', () {
      const event1 = TripMapLoadRequested(companyId: 'c1');
      const event2 = TripMapLoadRequested(companyId: 'c1');
      const event3 = TripMapLoadRequested(companyId: 'c2');
      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('TripMapLoadRequested props are correct', () {
      const event = TripMapLoadRequested(companyId: 'c1');
      expect(event.props, ['c1']);
    });

    test('TripMapTripSelected supports value equality', () {
      final event1 = TripMapTripSelected(trip: sampleTrips.first);
      final event2 = TripMapTripSelected(trip: sampleTrips.first);
      const event3 = TripMapTripSelected();
      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('TripMapTripSelected props are correct', () {
      const event = TripMapTripSelected();
      expect(event.props, [null]);
    });
  });

  group('TripMapState', () {
    test('supports value equality', () {
      const state1 = TripMapState();
      const state2 = TripMapState();
      expect(state1, equals(state2));
    });

    test('copyWith returns correct state', () {
      final initial = const TripMapState();

      final loaded = initial.copyWith(
        status: TripMapStatus.loaded,
        trips: sampleTrips,
      );
      expect(loaded.status, TripMapStatus.loaded);
      expect(loaded.trips, sampleTrips);
      expect(loaded.selectedTrip, isNull);
      expect(loaded.errorMessage, '');

      final withTrip = loaded.copyWith(selectedTrip: sampleTrips.first);
      expect(withTrip.selectedTrip, sampleTrips.first);
      expect(withTrip.trips, sampleTrips);

      final cleared = withTrip.copyWith(clearSelectedTrip: true);
      expect(cleared.selectedTrip, isNull);
      expect(cleared.trips, sampleTrips);
    });

    test('copyWith preserves values when not specified', () {
      final state = TripMapState(
        status: TripMapStatus.loaded,
        trips: sampleTrips,
        selectedTrip: sampleTrips.first,
        errorMessage: 'msg',
      );
      final copied = state.copyWith();
      expect(copied, equals(state));
    });

    test('props are correct', () {
      const state = TripMapState(
        status: TripMapStatus.loading,
        errorMessage: 'test',
      );
      expect(state.props, [
        TripMapStatus.loading,
        const <Trip>[],
        null,
        'test',
      ]);
    });
  });
}
