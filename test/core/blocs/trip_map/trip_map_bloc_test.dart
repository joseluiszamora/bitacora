import 'package:bitacora/core/blocs/trip_map/trip_map_bloc.dart';
import 'package:bitacora/core/data/models/trip.dart';
import 'package:bitacora/core/data/models/trip_log.dart';
import 'package:bitacora/core/data/repositories/trip_log_repository.dart';
import 'package:bitacora/core/data/repositories/trip_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTripRepository extends Mock implements TripRepository {}

class MockTripLogRepository extends Mock implements TripLogRepository {}

void main() {
  late MockTripRepository mockRepository;
  late MockTripLogRepository mockLogRepository;

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
    mockLogRepository = MockTripLogRepository();
  });

  final sampleLogs = [
    TripLog(
      id: 'log-1',
      tripId: 'trip-1',
      eventType: TripLogEventType.started,
      latitude: -17.7833,
      longitude: -63.1821,
      description: 'Viaje iniciado',
      createdAt: DateTime(2024, 1, 15, 8, 30),
    ),
    TripLog(
      id: 'log-2',
      tripId: 'trip-1',
      eventType: TripLogEventType.arrivedAtOrigin,
      latitude: -17.8000,
      longitude: -63.2000,
      createdAt: DateTime(2024, 1, 15, 9, 0),
    ),
    TripLog(
      id: 'log-3',
      tripId: 'trip-1',
      eventType: TripLogEventType.incident,
      // Sin ubicación
      createdAt: DateTime(2024, 1, 15, 10, 0),
    ),
  ];

  group('TripMapBloc', () {
    test('initial state is correct', () {
      final bloc = TripMapBloc(
        tripRepository: mockRepository,
        tripLogRepository: mockLogRepository,
      );
      expect(bloc.state, const TripMapState());
      expect(bloc.state.status, TripMapStatus.initial);
      expect(bloc.state.trips, isEmpty);
      expect(bloc.state.selectedTrip, isNull);
      expect(bloc.state.tripLogs, isEmpty);
      expect(bloc.state.selectedTripLog, isNull);
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
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
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
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
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
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
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
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
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
        'emits state with selected trip and loads trip logs',
        setUp: () {
          when(
            () => mockLogRepository.getByTrip('trip-1'),
          ).thenAnswer((_) async => sampleLogs);
        },
        seed: () =>
            TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
        act: (bloc) => bloc.add(TripMapTripSelected(trip: sampleTrips.first)),
        expect: () => [
          TripMapState(
            status: TripMapStatus.loaded,
            trips: sampleTrips,
            selectedTrip: sampleTrips.first,
          ),
          TripMapState(
            status: TripMapStatus.loaded,
            trips: sampleTrips,
            selectedTrip: sampleTrips.first,
            tripLogs: sampleLogs,
          ),
        ],
        verify: (_) {
          verify(() => mockLogRepository.getByTrip('trip-1')).called(1);
        },
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits state with null trip and clears logs when cleared',
        seed: () => TripMapState(
          status: TripMapStatus.loaded,
          trips: sampleTrips,
          selectedTrip: sampleTrips.first,
          tripLogs: sampleLogs,
        ),
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
        act: (bloc) => bloc.add(const TripMapTripSelected()),
        expect: () => [
          TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        ],
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits selected trip even if log loading fails',
        setUp: () {
          when(
            () => mockLogRepository.getByTrip('trip-1'),
          ).thenThrow(Exception('Log error'));
        },
        seed: () =>
            TripMapState(status: TripMapStatus.loaded, trips: sampleTrips),
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
        act: (bloc) => bloc.add(TripMapTripSelected(trip: sampleTrips.first)),
        expect: () => [
          TripMapState(
            status: TripMapStatus.loaded,
            trips: sampleTrips,
            selectedTrip: sampleTrips.first,
          ),
        ],
      );
    });

    group('TripMapLogSelected', () {
      blocTest<TripMapBloc, TripMapState>(
        'emits state with selected trip log',
        seed: () => TripMapState(
          status: TripMapStatus.loaded,
          trips: sampleTrips,
          selectedTrip: sampleTrips.first,
          tripLogs: sampleLogs,
        ),
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
        act: (bloc) => bloc.add(TripMapLogSelected(tripLog: sampleLogs.first)),
        expect: () => [
          TripMapState(
            status: TripMapStatus.loaded,
            trips: sampleTrips,
            selectedTrip: sampleTrips.first,
            tripLogs: sampleLogs,
            selectedTripLog: sampleLogs.first,
          ),
        ],
      );

      blocTest<TripMapBloc, TripMapState>(
        'emits state with null trip log when cleared',
        seed: () => TripMapState(
          status: TripMapStatus.loaded,
          trips: sampleTrips,
          selectedTrip: sampleTrips.first,
          tripLogs: sampleLogs,
          selectedTripLog: sampleLogs.first,
        ),
        build: () => TripMapBloc(
          tripRepository: mockRepository,
          tripLogRepository: mockLogRepository,
        ),
        act: (bloc) => bloc.add(const TripMapLogSelected()),
        expect: () => [
          TripMapState(
            status: TripMapStatus.loaded,
            trips: sampleTrips,
            selectedTrip: sampleTrips.first,
            tripLogs: sampleLogs,
          ),
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

    test('TripMapLogSelected supports value equality', () {
      final event1 = TripMapLogSelected(tripLog: sampleLogs.first);
      final event2 = TripMapLogSelected(tripLog: sampleLogs.first);
      const event3 = TripMapLogSelected();
      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('TripMapLogSelected props are correct', () {
      const event = TripMapLogSelected();
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
        const <TripLog>[],
        null,
        'test',
      ]);
    });

    test('copyWith handles tripLogs and selectedTripLog', () {
      final state = TripMapState(
        status: TripMapStatus.loaded,
        trips: sampleTrips,
        selectedTrip: sampleTrips.first,
      );

      final withLogs = state.copyWith(tripLogs: sampleLogs);
      expect(withLogs.tripLogs, sampleLogs);
      expect(withLogs.selectedTripLog, isNull);

      final withSelectedLog = withLogs.copyWith(
        selectedTripLog: sampleLogs.first,
      );
      expect(withSelectedLog.selectedTripLog, sampleLogs.first);
      expect(withSelectedLog.tripLogs, sampleLogs);

      final clearedLog = withSelectedLog.copyWith(clearSelectedTripLog: true);
      expect(clearedLog.selectedTripLog, isNull);
      expect(clearedLog.tripLogs, sampleLogs);
    });
  });
}
