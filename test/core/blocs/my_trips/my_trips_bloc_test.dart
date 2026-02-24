import 'package:bitacora/core/blocs/my_trips/my_trips_bloc.dart';
import 'package:bitacora/core/data/models/trip.dart';
import 'package:bitacora/core/data/models/user_role.dart';
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

  group('MyTripsBloc', () {
    test('initial state is correct', () {
      final bloc = MyTripsBloc(tripRepository: mockRepository);
      expect(bloc.state, const MyTripsState());
      expect(bloc.state.status, MyTripsStatus.initial);
      expect(bloc.state.trips, isEmpty);
      expect(bloc.state.errorMessage, isEmpty);
      bloc.close();
    });

    group('MyTripsLoadRequested', () {
      group('driver role', () {
        blocTest<MyTripsBloc, MyTripsState>(
          'emits [loading, loaded] with getByDriver on success',
          setUp: () {
            when(() => mockRepository.getByDriver('driver-1'))
                .thenAnswer((_) async => sampleTrips);
          },
          build: () => MyTripsBloc(tripRepository: mockRepository),
          act: (bloc) => bloc.add(const MyTripsLoadRequested(
            userId: 'driver-1',
            role: UserRole.driver,
            companyId: 'comp-1',
          )),
          expect: () => [
            const MyTripsState(status: MyTripsStatus.loading),
            MyTripsState(status: MyTripsStatus.loaded, trips: sampleTrips),
          ],
          verify: (_) {
            verify(() => mockRepository.getByDriver('driver-1')).called(1);
            verifyNever(() => mockRepository.getByCompany(any()));
            verifyNever(() => mockRepository.getAll());
          },
        );

        blocTest<MyTripsBloc, MyTripsState>(
          'emits [loading, failure] on error',
          setUp: () {
            when(() => mockRepository.getByDriver('driver-1'))
                .thenThrow(Exception('Network error'));
          },
          build: () => MyTripsBloc(tripRepository: mockRepository),
          act: (bloc) => bloc.add(const MyTripsLoadRequested(
            userId: 'driver-1',
            role: UserRole.driver,
          )),
          expect: () => [
            const MyTripsState(status: MyTripsStatus.loading),
            isA<MyTripsState>()
                .having((s) => s.status, 'status', MyTripsStatus.failure)
                .having((s) => s.errorMessage, 'errorMessage',
                    contains('Network error')),
          ],
        );
      });

      group('admin role', () {
        blocTest<MyTripsBloc, MyTripsState>(
          'emits [loading, loaded] with getByCompany when companyId provided',
          setUp: () {
            when(() => mockRepository.getByCompany('comp-1'))
                .thenAnswer((_) async => sampleTrips);
          },
          build: () => MyTripsBloc(tripRepository: mockRepository),
          act: (bloc) => bloc.add(const MyTripsLoadRequested(
            userId: 'admin-1',
            role: UserRole.admin,
            companyId: 'comp-1',
          )),
          expect: () => [
            const MyTripsState(status: MyTripsStatus.loading),
            MyTripsState(status: MyTripsStatus.loaded, trips: sampleTrips),
          ],
          verify: (_) {
            verify(() => mockRepository.getByCompany('comp-1')).called(1);
            verifyNever(() => mockRepository.getByDriver(any()));
          },
        );

        blocTest<MyTripsBloc, MyTripsState>(
          'emits [loading, loaded] with getAll when companyId is null',
          setUp: () {
            when(() => mockRepository.getAll())
                .thenAnswer((_) async => sampleTrips);
          },
          build: () => MyTripsBloc(tripRepository: mockRepository),
          act: (bloc) => bloc.add(const MyTripsLoadRequested(
            userId: 'sa-1',
            role: UserRole.admin,
          )),
          expect: () => [
            const MyTripsState(status: MyTripsStatus.loading),
            MyTripsState(status: MyTripsStatus.loaded, trips: sampleTrips),
          ],
          verify: (_) {
            verify(() => mockRepository.getAll()).called(1);
          },
        );

        blocTest<MyTripsBloc, MyTripsState>(
          'emits [loading, loaded] with getAll when companyId is empty',
          setUp: () {
            when(() => mockRepository.getAll())
                .thenAnswer((_) async => sampleTrips);
          },
          build: () => MyTripsBloc(tripRepository: mockRepository),
          act: (bloc) => bloc.add(const MyTripsLoadRequested(
            userId: 'sa-1',
            role: UserRole.admin,
            companyId: '',
          )),
          expect: () => [
            const MyTripsState(status: MyTripsStatus.loading),
            MyTripsState(status: MyTripsStatus.loaded, trips: sampleTrips),
          ],
        );
      });

      group('supervisor role', () {
        blocTest<MyTripsBloc, MyTripsState>(
          'emits [loading, loaded] with getByCompany',
          setUp: () {
            when(() => mockRepository.getByCompany('comp-1'))
                .thenAnswer((_) async => sampleTrips);
          },
          build: () => MyTripsBloc(tripRepository: mockRepository),
          act: (bloc) => bloc.add(const MyTripsLoadRequested(
            userId: 'sup-1',
            role: UserRole.supervisor,
            companyId: 'comp-1',
          )),
          expect: () => [
            const MyTripsState(status: MyTripsStatus.loading),
            MyTripsState(status: MyTripsStatus.loaded, trips: sampleTrips),
          ],
        );
      });

      blocTest<MyTripsBloc, MyTripsState>(
        'emits loaded with empty list when no trips found',
        setUp: () {
          when(() => mockRepository.getByDriver('driver-2'))
              .thenAnswer((_) async => []);
        },
        build: () => MyTripsBloc(tripRepository: mockRepository),
        act: (bloc) => bloc.add(const MyTripsLoadRequested(
          userId: 'driver-2',
          role: UserRole.driver,
        )),
        expect: () => [
          const MyTripsState(status: MyTripsStatus.loading),
          const MyTripsState(status: MyTripsStatus.loaded, trips: []),
        ],
      );
    });
  });

  group('MyTripsEvent', () {
    test('MyTripsLoadRequested supports value equality', () {
      const event1 = MyTripsLoadRequested(
        userId: 'u1',
        role: UserRole.driver,
        companyId: 'c1',
      );
      const event2 = MyTripsLoadRequested(
        userId: 'u1',
        role: UserRole.driver,
        companyId: 'c1',
      );
      const event3 = MyTripsLoadRequested(
        userId: 'u2',
        role: UserRole.admin,
      );
      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('MyTripsLoadRequested props are correct', () {
      const event = MyTripsLoadRequested(
        userId: 'u1',
        role: UserRole.driver,
        companyId: 'c1',
      );
      expect(event.props, ['u1', UserRole.driver, 'c1']);
    });
  });

  group('MyTripsState', () {
    test('supports value equality', () {
      const state1 = MyTripsState();
      const state2 = MyTripsState();
      expect(state1, equals(state2));
    });

    test('copyWith returns correct state', () {
      final initial = const MyTripsState();

      final loaded = initial.copyWith(
        status: MyTripsStatus.loaded,
        trips: sampleTrips,
      );
      expect(loaded.status, MyTripsStatus.loaded);
      expect(loaded.trips, sampleTrips);
      expect(loaded.errorMessage, '');

      final withError = initial.copyWith(
        status: MyTripsStatus.failure,
        errorMessage: 'error',
      );
      expect(withError.status, MyTripsStatus.failure);
      expect(withError.errorMessage, 'error');
      expect(withError.trips, isEmpty);
    });

    test('copyWith preserves values when not specified', () {
      final state = MyTripsState(
        status: MyTripsStatus.loaded,
        trips: sampleTrips,
        errorMessage: 'msg',
      );
      final copied = state.copyWith();
      expect(copied, equals(state));
    });

    test('props are correct', () {
      const state = MyTripsState(
        status: MyTripsStatus.loading,
        errorMessage: 'test',
      );
      expect(state.props, [MyTripsStatus.loading, const <Trip>[], 'test']);
    });
  });
}
