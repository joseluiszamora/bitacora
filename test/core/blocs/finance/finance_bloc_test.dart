import 'package:bitacora/core/blocs/finance/finance_bloc.dart';
import 'package:bitacora/core/data/models/finance_category.dart';
import 'package:bitacora/core/data/models/finance_group.dart';
import 'package:bitacora/core/data/models/finance_record.dart';
import 'package:bitacora/core/data/repositories/finance_category_repository.dart';
import 'package:bitacora/core/data/repositories/finance_group_repository.dart';
import 'package:bitacora/core/data/repositories/finance_record_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFinanceGroupRepository extends Mock
    implements FinanceGroupRepository {}

class MockFinanceCategoryRepository extends Mock
    implements FinanceCategoryRepository {}

class MockFinanceRecordRepository extends Mock
    implements FinanceRecordRepository {}

void main() {
  // ─── Datos de prueba ─────────────────────────────────────────────────

  const companyId = 'comp-1';
  final now = DateTime(2025, 1, 15);

  final group1 = FinanceGroup(
    id: 'g-1',
    companyId: companyId,
    name: 'Gastos de enero',
    description: 'Gastos del mes de enero',
    isActive: true,
    createdAt: now,
  );

  final group2 = FinanceGroup(
    id: 'g-2',
    companyId: companyId,
    name: 'Reparación vehículo',
    isActive: false,
    createdAt: now,
  );

  final category1 = FinanceCategory(
    id: 'c-1',
    companyId: companyId,
    name: 'Pago por viaje',
    description: 'Ingresos por viajes realizados',
    isActive: true,
    createdAt: now,
  );

  final category2 = FinanceCategory(
    id: 'c-2',
    companyId: companyId,
    name: 'Reparación de motor',
    isActive: true,
    createdAt: now,
  );

  final record1 = FinanceRecord(
    id: 'r-1',
    companyId: companyId,
    groupId: 'g-1',
    categoryId: 'c-1',
    type: FinanceRecordType.income,
    amount: 1500.0,
    description: 'Viaje La Paz - Oruro',
    recordDate: now,
    createdAt: now,
    group: group1,
    category: category1,
  );

  final record2 = FinanceRecord(
    id: 'r-2',
    companyId: companyId,
    groupId: 'g-1',
    categoryId: 'c-2',
    type: FinanceRecordType.expense,
    amount: 500.0,
    description: 'Cambio de aceite',
    recordDate: now,
    createdAt: now,
    group: group1,
    category: category2,
  );

  final record3 = FinanceRecord(
    id: 'r-3',
    companyId: companyId,
    groupId: 'g-2',
    categoryId: 'c-2',
    type: FinanceRecordType.expense,
    amount: 3000.0,
    description: 'Motor nuevo',
    recordDate: now,
    createdAt: now,
    group: group2,
    category: category2,
  );

  final sampleGroups = [group1, group2];
  final sampleCategories = [category1, category2];
  final sampleRecords = [record1, record2, record3];

  // ─── Mocks ───────────────────────────────────────────────────────────

  late MockFinanceGroupRepository mockGroupRepo;
  late MockFinanceCategoryRepository mockCategoryRepo;
  late MockFinanceRecordRepository mockRecordRepo;

  setUp(() {
    mockGroupRepo = MockFinanceGroupRepository();
    mockCategoryRepo = MockFinanceCategoryRepository();
    mockRecordRepo = MockFinanceRecordRepository();
  });

  FinanceBloc buildBloc() => FinanceBloc(
    groupRepository: mockGroupRepo,
    categoryRepository: mockCategoryRepo,
    recordRepository: mockRecordRepo,
  );

  // ═══════════════════════════════════════════════════════════════════════
  // Modelos
  // ═══════════════════════════════════════════════════════════════════════

  group('FinanceGroup model', () {
    test('empty group has isEmpty true', () {
      expect(FinanceGroup.empty.isEmpty, isTrue);
      expect(FinanceGroup.empty.isNotEmpty, isFalse);
    });

    test('non-empty group has isNotEmpty true', () {
      expect(group1.isNotEmpty, isTrue);
      expect(group1.isEmpty, isFalse);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'g-1',
        'company_id': 'comp-1',
        'name': 'Test',
        'description': 'Desc',
        'is_active': true,
        'created_at': '2025-01-15T00:00:00.000',
      };
      final result = FinanceGroup.fromJson(json);
      expect(result.id, 'g-1');
      expect(result.companyId, 'comp-1');
      expect(result.name, 'Test');
      expect(result.description, 'Desc');
      expect(result.isActive, isTrue);
      expect(result.createdAt, isNotNull);
    });

    test('fromJson handles missing fields with defaults', () {
      final result = FinanceGroup.fromJson({});
      expect(result.id, '');
      expect(result.name, '');
      expect(result.isActive, isTrue);
      expect(result.description, isNull);
    });

    test('toJson produces correct map', () {
      final json = group1.toJson();
      expect(json['id'], 'g-1');
      expect(json['company_id'], companyId);
      expect(json['name'], 'Gastos de enero');
      expect(json['is_active'], isTrue);
    });

    test('copyWith creates a new object with changed values', () {
      final copy = group1.copyWith(name: 'Gastos de febrero', isActive: false);
      expect(copy.name, 'Gastos de febrero');
      expect(copy.isActive, isFalse);
      expect(copy.id, group1.id); // sin cambio
    });

    test('props returns all fields for equality', () {
      expect(group1.props.length, 6);
    });

    test('two groups with same data are equal', () {
      final copy = group1.copyWith();
      expect(copy, equals(group1));
    });
  });

  group('FinanceCategory model', () {
    test('empty category has isEmpty true', () {
      expect(FinanceCategory.empty.isEmpty, isTrue);
      expect(FinanceCategory.empty.isNotEmpty, isFalse);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'c-1',
        'company_id': 'comp-1',
        'name': 'Pago por viaje',
        'description': 'Desc',
        'is_active': false,
        'created_at': '2025-01-15T00:00:00.000',
      };
      final result = FinanceCategory.fromJson(json);
      expect(result.id, 'c-1');
      expect(result.name, 'Pago por viaje');
      expect(result.isActive, isFalse);
    });

    test('toJson produces correct map', () {
      final json = category1.toJson();
      expect(json['name'], 'Pago por viaje');
      expect(json['is_active'], isTrue);
    });

    test('copyWith creates a new object', () {
      final copy = category1.copyWith(name: 'Impuestos');
      expect(copy.name, 'Impuestos');
      expect(copy.id, category1.id);
    });

    test('props returns all fields for equality', () {
      expect(category1.props.length, 6);
    });
  });

  group('FinanceRecord model', () {
    test('empty record has isEmpty true', () {
      expect(FinanceRecord.empty.isEmpty, isTrue);
    });

    test('isIncome and isExpense getters work', () {
      expect(record1.isIncome, isTrue);
      expect(record1.isExpense, isFalse);
      expect(record2.isIncome, isFalse);
      expect(record2.isExpense, isTrue);
    });

    test('displayName formats correctly for income', () {
      expect(record1.displayName, '📈 Ingreso — Bs. 1500.00');
    });

    test('displayName formats correctly for expense', () {
      expect(record2.displayName, '📉 Egreso — Bs. 500.00');
    });

    test('fromJson parses basic fields', () {
      final json = {
        'id': 'r-x',
        'company_id': 'comp-1',
        'group_id': 'g-1',
        'category_id': 'c-1',
        'type': 'INCOME',
        'amount': 200.5,
        'description': 'Test',
        'record_date': '2025-01-15',
        'created_at': '2025-01-15T00:00:00.000',
      };
      final result = FinanceRecord.fromJson(json);
      expect(result.id, 'r-x');
      expect(result.type, FinanceRecordType.income);
      expect(result.amount, 200.5);
      expect(result.group, isNull);
      expect(result.category, isNull);
    });

    test('fromJson parses joins when present', () {
      final json = {
        'id': 'r-x',
        'company_id': 'comp-1',
        'group_id': 'g-1',
        'category_id': 'c-1',
        'type': 'EXPENSE',
        'amount': 100,
        'finance_groups': {
          'id': 'g-1',
          'company_id': 'comp-1',
          'name': 'Grupo join',
        },
        'finance_categories': {
          'id': 'c-1',
          'company_id': 'comp-1',
          'name': 'Cat join',
        },
      };
      final result = FinanceRecord.fromJson(json);
      expect(result.group, isNotNull);
      expect(result.group!.name, 'Grupo join');
      expect(result.category, isNotNull);
      expect(result.category!.name, 'Cat join');
    });

    test('fromJson defaults type to EXPENSE for unknown values', () {
      final json = {
        'id': 'r-x',
        'company_id': 'comp-1',
        'group_id': 'g-1',
        'category_id': 'c-1',
        'type': 'UNKNOWN_TYPE',
        'amount': 0,
      };
      final result = FinanceRecord.fromJson(json);
      expect(result.type, FinanceRecordType.expense);
    });

    test('toJson produces correct map', () {
      final json = record1.toJson();
      expect(json['type'], 'INCOME');
      expect(json['amount'], 1500.0);
      expect(json['group_id'], 'g-1');
    });

    test('copyWith creates a new record', () {
      final copy = record1.copyWith(amount: 2000.0);
      expect(copy.amount, 2000.0);
      expect(copy.type, FinanceRecordType.income);
    });

    test('props includes all fields', () {
      expect(record1.props.length, 11);
    });
  });

  group('FinanceRecordType enum', () {
    test('values have correct value strings', () {
      expect(FinanceRecordType.income.value, 'INCOME');
      expect(FinanceRecordType.expense.value, 'EXPENSE');
    });

    test('labels are in Spanish', () {
      expect(FinanceRecordType.income.label, 'Ingreso');
      expect(FinanceRecordType.expense.label, 'Egreso');
    });

    test('icons return emoji', () {
      expect(FinanceRecordType.income.icon, '📈');
      expect(FinanceRecordType.expense.icon, '📉');
    });

    test('fromValue returns correct enum', () {
      expect(FinanceRecordType.fromValue('INCOME'), FinanceRecordType.income);
      expect(FinanceRecordType.fromValue('EXPENSE'), FinanceRecordType.expense);
    });

    test('fromValue defaults to expense for unknown', () {
      expect(FinanceRecordType.fromValue('NOPE'), FinanceRecordType.expense);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // Events
  // ═══════════════════════════════════════════════════════════════════════

  group('Finance events', () {
    test('FinanceLoadRequested props', () {
      const e = FinanceLoadRequested(companyId: 'comp-1');
      expect(e.props, ['comp-1']);
    });

    test('FinanceGroupCreateRequested props', () {
      const e = FinanceGroupCreateRequested(
        companyId: 'comp-1',
        name: 'G',
        description: 'D',
      );
      expect(e.props, ['comp-1', 'G', 'D']);
    });

    test('FinanceGroupUpdateRequested props', () {
      const e = FinanceGroupUpdateRequested(
        id: 'g-1',
        name: 'Updated',
        isActive: false,
      );
      expect(e.props, ['g-1', 'Updated', null, false]);
    });

    test('FinanceGroupDeleteRequested props', () {
      const e = FinanceGroupDeleteRequested('g-1');
      expect(e.props, ['g-1']);
    });

    test('FinanceCategoryCreateRequested props', () {
      const e = FinanceCategoryCreateRequested(
        companyId: 'comp-1',
        name: 'Cat',
      );
      expect(e.props, ['comp-1', 'Cat', null]);
    });

    test('FinanceCategoryUpdateRequested props', () {
      const e = FinanceCategoryUpdateRequested(id: 'c-1', isActive: true);
      expect(e.props, ['c-1', null, null, true]);
    });

    test('FinanceCategoryDeleteRequested props', () {
      const e = FinanceCategoryDeleteRequested('c-1');
      expect(e.props, ['c-1']);
    });

    test('FinanceRecordCreateRequested props', () {
      final e = FinanceRecordCreateRequested(
        companyId: 'comp-1',
        groupId: 'g-1',
        categoryId: 'c-1',
        type: FinanceRecordType.income,
        amount: 100.0,
        recordDate: now,
      );
      expect(e.props.length, 7);
    });

    test('FinanceRecordUpdateRequested props', () {
      const e = FinanceRecordUpdateRequested(id: 'r-1', amount: 200.0);
      expect(e.props.first, 'r-1');
    });

    test('FinanceRecordDeleteRequested props', () {
      const e = FinanceRecordDeleteRequested('r-1');
      expect(e.props, ['r-1']);
    });

    test('FinanceFilterByGroupRequested props', () {
      const e1 = FinanceFilterByGroupRequested(groupId: 'g-1');
      expect(e1.props, ['g-1']);
      const e2 = FinanceFilterByGroupRequested();
      expect(e2.props, [null]);
    });

    test('two events with same props are equal', () {
      const a = FinanceLoadRequested(companyId: 'comp-1');
      const b = FinanceLoadRequested(companyId: 'comp-1');
      expect(a, equals(b));
    });

    test('two events with different props are not equal', () {
      const a = FinanceLoadRequested(companyId: 'comp-1');
      const b = FinanceLoadRequested(companyId: 'comp-2');
      expect(a, isNot(equals(b)));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // State
  // ═══════════════════════════════════════════════════════════════════════

  group('FinanceState', () {
    test('default state has correct values', () {
      const state = FinanceState();
      expect(state.status, FinanceStatus.initial);
      expect(state.groups, isEmpty);
      expect(state.categories, isEmpty);
      expect(state.records, isEmpty);
      expect(state.filterGroupId, isNull);
      expect(state.errorMessage, isEmpty);
    });

    test('isIdle is true for non-transient statuses', () {
      expect(const FinanceState().isIdle, isTrue);
      expect(const FinanceState(status: FinanceStatus.loaded).isIdle, isTrue);
      expect(const FinanceState(status: FinanceStatus.success).isIdle, isTrue);
      expect(const FinanceState(status: FinanceStatus.failure).isIdle, isTrue);
    });

    test('isIdle is false for transient statuses', () {
      expect(const FinanceState(status: FinanceStatus.loading).isIdle, isFalse);
      expect(
        const FinanceState(status: FinanceStatus.creating).isIdle,
        isFalse,
      );
      expect(
        const FinanceState(status: FinanceStatus.updating).isIdle,
        isFalse,
      );
      expect(
        const FinanceState(status: FinanceStatus.deleting).isIdle,
        isFalse,
      );
    });

    test('filteredRecords returns all when no filter', () {
      final state = FinanceState(records: sampleRecords);
      expect(state.filteredRecords.length, 3);
    });

    test('filteredRecords filters by group', () {
      final state = FinanceState(records: sampleRecords, filterGroupId: 'g-1');
      expect(state.filteredRecords.length, 2);
      expect(state.filteredRecords.every((r) => r.groupId == 'g-1'), isTrue);
    });

    test('totalIncome sums income records in filtered', () {
      final state = FinanceState(records: sampleRecords);
      expect(state.totalIncome, 1500.0);
    });

    test('totalExpense sums expense records in filtered', () {
      final state = FinanceState(records: sampleRecords);
      expect(state.totalExpense, 3500.0); // 500 + 3000
    });

    test('balance computes income - expense', () {
      final state = FinanceState(records: sampleRecords);
      expect(state.balance, -2000.0);
    });

    test('totalIncome / totalExpense respect group filter', () {
      final state = FinanceState(records: sampleRecords, filterGroupId: 'g-1');
      expect(state.totalIncome, 1500.0);
      expect(state.totalExpense, 500.0);
      expect(state.balance, 1000.0);
    });

    test('activeGroups returns only active groups', () {
      final state = FinanceState(groups: sampleGroups);
      expect(state.activeGroups.length, 1);
      expect(state.activeGroups.first.id, 'g-1');
    });

    test('activeCategories returns only active', () {
      final state = FinanceState(categories: sampleCategories);
      expect(state.activeCategories.length, 2);
    });

    test('copyWith preserves existing values', () {
      final state = FinanceState(
        status: FinanceStatus.loaded,
        groups: sampleGroups,
        errorMessage: 'err',
      );
      final copy = state.copyWith(status: FinanceStatus.success);
      expect(copy.status, FinanceStatus.success);
      expect(copy.groups, sampleGroups);
      expect(copy.errorMessage, 'err');
    });

    test('copyWith clearFilterGroupId works', () {
      final state = FinanceState(filterGroupId: 'g-1');
      final copy = state.copyWith(clearFilterGroupId: true);
      expect(copy.filterGroupId, isNull);
    });

    test('props includes all fields', () {
      const state = FinanceState();
      expect(state.props.length, 6);
    });

    test('two states with same data are equal', () {
      final a = FinanceState(groups: sampleGroups);
      final b = FinanceState(groups: sampleGroups);
      expect(a, equals(b));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════
  // Bloc
  // ═══════════════════════════════════════════════════════════════════════

  group('FinanceBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state, const FinanceState());
      expect(bloc.state.status, FinanceStatus.initial);
      bloc.close();
    });

    // ─── Load ──────────────────────────────────────────────────────────

    group('FinanceLoadRequested', () {
      blocTest<FinanceBloc, FinanceState>(
        'emits [loading, loaded] on success',
        setUp: () {
          when(
            () => mockGroupRepo.getByCompany(companyId),
          ).thenAnswer((_) async => sampleGroups);
          when(
            () => mockCategoryRepo.getByCompany(companyId),
          ).thenAnswer((_) async => sampleCategories);
          when(
            () => mockRecordRepo.getByCompany(companyId),
          ).thenAnswer((_) async => sampleRecords);
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const FinanceLoadRequested(companyId: companyId)),
        expect: () => [
          const FinanceState(status: FinanceStatus.loading),
          FinanceState(
            status: FinanceStatus.loaded,
            groups: sampleGroups,
            categories: sampleCategories,
            records: sampleRecords,
          ),
        ],
        verify: (_) {
          verify(() => mockGroupRepo.getByCompany(companyId)).called(1);
          verify(() => mockCategoryRepo.getByCompany(companyId)).called(1);
          verify(() => mockRecordRepo.getByCompany(companyId)).called(1);
        },
      );

      blocTest<FinanceBloc, FinanceState>(
        'emits [loading, failure] on error',
        setUp: () {
          when(
            () => mockGroupRepo.getByCompany(companyId),
          ).thenThrow(Exception('DB error'));
          when(
            () => mockCategoryRepo.getByCompany(companyId),
          ).thenAnswer((_) async => []);
          when(
            () => mockRecordRepo.getByCompany(companyId),
          ).thenAnswer((_) async => []);
        },
        build: buildBloc,
        act: (bloc) =>
            bloc.add(const FinanceLoadRequested(companyId: companyId)),
        expect: () => [
          const FinanceState(status: FinanceStatus.loading),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('DB error'),
              ),
        ],
      );
    });

    // ─── Group CRUD ────────────────────────────────────────────────────

    group('Group CRUD', () {
      blocTest<FinanceBloc, FinanceState>(
        'create group emits [creating, success] and adds group sorted',
        setUp: () {
          final newGroup = FinanceGroup(
            id: 'g-new',
            companyId: companyId,
            name: 'AAA Nuevo',
          );
          when(
            () => mockGroupRepo.create(
              companyId: companyId,
              name: 'AAA Nuevo',
              description: null,
            ),
          ).thenAnswer((_) async => newGroup);
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, groups: [group1]),
        act: (bloc) => bloc.add(
          const FinanceGroupCreateRequested(
            companyId: companyId,
            name: 'AAA Nuevo',
          ),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.creating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.groups.length, 'groups.length', 2)
              .having((s) => s.groups.first.name, 'first name', 'AAA Nuevo'),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'create group emits [creating, failure] on duplicate',
        setUp: () {
          when(
            () => mockGroupRepo.create(
              companyId: companyId,
              name: 'Dup',
              description: null,
            ),
          ).thenThrow(Exception('duplicate key unique'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const FinanceGroupCreateRequested(companyId: companyId, name: 'Dup'),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.creating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'Ya existe un registro con ese nombre.',
              ),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'update group emits [updating, success]',
        setUp: () {
          when(
            () => mockGroupRepo.update(
              id: 'g-1',
              name: 'Updated',
              description: null,
              isActive: null,
            ),
          ).thenAnswer((_) async => group1.copyWith(name: 'Updated'));
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, groups: [group1]),
        act: (bloc) => bloc.add(
          const FinanceGroupUpdateRequested(id: 'g-1', name: 'Updated'),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.updating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.groups.first.name, 'name', 'Updated'),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'delete group emits [deleting, success] and removes from list',
        setUp: () {
          when(() => mockGroupRepo.delete('g-1')).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, groups: sampleGroups),
        act: (bloc) => bloc.add(const FinanceGroupDeleteRequested('g-1')),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.deleting,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.groups.length, 'groups.length', 1)
              .having((s) => s.groups.first.id, 'remaining id', 'g-2'),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'delete group emits [deleting, failure] with foreign key error',
        setUp: () {
          when(
            () => mockGroupRepo.delete('g-1'),
          ).thenThrow(Exception('foreign key constraint'));
        },
        build: buildBloc,
        seed: () => FinanceState(groups: sampleGroups),
        act: (bloc) => bloc.add(const FinanceGroupDeleteRequested('g-1')),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.deleting,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'No se puede eliminar: tiene registros asociados.',
              ),
        ],
      );
    });

    // ─── Category CRUD ─────────────────────────────────────────────────

    group('Category CRUD', () {
      blocTest<FinanceBloc, FinanceState>(
        'create category emits [creating, success]',
        setUp: () {
          final newCat = FinanceCategory(
            id: 'c-new',
            companyId: companyId,
            name: 'Impuestos',
          );
          when(
            () => mockCategoryRepo.create(
              companyId: companyId,
              name: 'Impuestos',
              description: null,
            ),
          ).thenAnswer((_) async => newCat);
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, categories: [category1]),
        act: (bloc) => bloc.add(
          const FinanceCategoryCreateRequested(
            companyId: companyId,
            name: 'Impuestos',
          ),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.creating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.categories.length, 'categories.length', 2),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'update category emits [updating, success]',
        setUp: () {
          when(
            () => mockCategoryRepo.update(
              id: 'c-1',
              name: 'Renamed',
              description: null,
              isActive: null,
            ),
          ).thenAnswer((_) async => category1.copyWith(name: 'Renamed'));
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, categories: [category1]),
        act: (bloc) => bloc.add(
          const FinanceCategoryUpdateRequested(id: 'c-1', name: 'Renamed'),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.updating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.categories.first.name, 'name', 'Renamed'),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'delete category emits [deleting, success]',
        setUp: () {
          when(() => mockCategoryRepo.delete('c-1')).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () => FinanceState(
          status: FinanceStatus.loaded,
          categories: sampleCategories,
        ),
        act: (bloc) => bloc.add(const FinanceCategoryDeleteRequested('c-1')),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.deleting,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.categories.length, 'categories.length', 1),
        ],
      );
    });

    // ─── Record CRUD ───────────────────────────────────────────────────

    group('Record CRUD', () {
      blocTest<FinanceBloc, FinanceState>(
        'create record emits [creating, success] and prepends',
        setUp: () {
          when(
            () => mockRecordRepo.create(
              companyId: companyId,
              groupId: 'g-1',
              categoryId: 'c-1',
              type: FinanceRecordType.income,
              amount: 800.0,
              description: null,
              recordDate: now,
            ),
          ).thenAnswer(
            (_) async => FinanceRecord(
              id: 'r-new',
              companyId: companyId,
              groupId: 'g-1',
              categoryId: 'c-1',
              type: FinanceRecordType.income,
              amount: 800.0,
              recordDate: now,
            ),
          );
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, records: [record1]),
        act: (bloc) => bloc.add(
          FinanceRecordCreateRequested(
            companyId: companyId,
            groupId: 'g-1',
            categoryId: 'c-1',
            type: FinanceRecordType.income,
            amount: 800.0,
            recordDate: now,
          ),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.creating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.records.length, 'records.length', 2)
              .having((s) => s.records.first.id, 'first id', 'r-new'),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'update record emits [updating, success]',
        setUp: () {
          when(
            () => mockRecordRepo.update(
              id: 'r-1',
              groupId: null,
              categoryId: null,
              type: null,
              amount: 2000.0,
              description: null,
              recordDate: null,
            ),
          ).thenAnswer((_) async => record1.copyWith(amount: 2000.0));
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, records: [record1]),
        act: (bloc) => bloc.add(
          const FinanceRecordUpdateRequested(id: 'r-1', amount: 2000.0),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.updating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.records.first.amount, 'amount', 2000.0),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'delete record emits [deleting, success]',
        setUp: () {
          when(() => mockRecordRepo.delete('r-1')).thenAnswer((_) async {});
        },
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, records: sampleRecords),
        act: (bloc) => bloc.add(const FinanceRecordDeleteRequested('r-1')),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.deleting,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.success)
              .having((s) => s.records.length, 'records.length', 2),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'create record emits failure on permission error',
        setUp: () {
          when(
            () => mockRecordRepo.create(
              companyId: companyId,
              groupId: 'g-1',
              categoryId: 'c-1',
              type: FinanceRecordType.expense,
              amount: 50.0,
              description: null,
              recordDate: null,
            ),
          ).thenThrow(Exception('permission denied'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(
          const FinanceRecordCreateRequested(
            companyId: companyId,
            groupId: 'g-1',
            categoryId: 'c-1',
            type: FinanceRecordType.expense,
            amount: 50.0,
          ),
        ),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.creating,
          ),
          isA<FinanceState>()
              .having((s) => s.status, 'status', FinanceStatus.failure)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                'No tienes permisos para realizar esta acción.',
              ),
        ],
      );
    });

    // ─── Filter ────────────────────────────────────────────────────────

    group('FinanceFilterByGroupRequested', () {
      blocTest<FinanceBloc, FinanceState>(
        'sets filterGroupId',
        build: buildBloc,
        seed: () =>
            FinanceState(status: FinanceStatus.loaded, records: sampleRecords),
        act: (bloc) =>
            bloc.add(const FinanceFilterByGroupRequested(groupId: 'g-1')),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.filterGroupId,
            'filterGroupId',
            'g-1',
          ),
        ],
      );

      blocTest<FinanceBloc, FinanceState>(
        'clears filterGroupId when null',
        build: buildBloc,
        seed: () => FinanceState(
          status: FinanceStatus.loaded,
          records: sampleRecords,
          filterGroupId: 'g-1',
        ),
        act: (bloc) => bloc.add(const FinanceFilterByGroupRequested()),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.filterGroupId,
            'filterGroupId',
            isNull,
          ),
        ],
      );
    });

    // ─── _mapError ─────────────────────────────────────────────────────

    group('error mapping', () {
      blocTest<FinanceBloc, FinanceState>(
        'maps unknown error to generic message',
        setUp: () {
          when(
            () => mockGroupRepo.delete('g-x'),
          ).thenThrow(Exception('something weird'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const FinanceGroupDeleteRequested('g-x')),
        expect: () => [
          isA<FinanceState>().having(
            (s) => s.status,
            'status',
            FinanceStatus.deleting,
          ),
          isA<FinanceState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            'Error inesperado. Intenta de nuevo.',
          ),
        ],
      );
    });
  });
}
