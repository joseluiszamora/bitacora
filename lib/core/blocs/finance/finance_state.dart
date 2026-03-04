part of 'finance_bloc.dart';

enum FinanceStatus {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  failure,
}

/// Modelo ligero de usuario para los dropdowns del módulo de finanzas.
class FinanceUser extends Equatable {
  const FinanceUser({required this.id, required this.name});

  final String id;
  final String name;

  factory FinanceUser.fromJson(Map<String, dynamic> json) {
    return FinanceUser(
      id: json['id'] as String? ?? '',
      name: json['full_name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

final class FinanceState extends Equatable {
  const FinanceState({
    this.status = FinanceStatus.initial,
    this.groups = const [],
    this.categories = const [],
    this.records = const [],
    this.companyUsers = const [],
    this.filterGroupId,
    this.errorMessage = '',
  });

  final FinanceStatus status;
  final List<FinanceGroup> groups;
  final List<FinanceCategory> categories;
  final List<FinanceRecord> records;
  final List<FinanceUser> companyUsers;
  final String? filterGroupId;
  final String errorMessage;

  /// Indica si se puede interactuar con la UI.
  bool get isIdle =>
      status == FinanceStatus.initial ||
      status == FinanceStatus.loaded ||
      status == FinanceStatus.success ||
      status == FinanceStatus.failure;

  /// Registros filtrados por grupo (si hay filtro activo).
  List<FinanceRecord> get filteredRecords {
    if (filterGroupId == null) return records;
    return records.where((r) => r.groupId == filterGroupId).toList();
  }

  /// Total de ingresos de los registros visibles.
  double get totalIncome => filteredRecords
      .where((r) => r.isIncome)
      .fold(0, (sum, r) => sum + r.amount);

  /// Total de egresos de los registros visibles.
  double get totalExpense => filteredRecords
      .where((r) => r.isExpense)
      .fold(0, (sum, r) => sum + r.amount);

  /// Balance (ingresos - egresos).
  double get balance => totalIncome - totalExpense;

  /// Grupos activos.
  List<FinanceGroup> get activeGroups =>
      groups.where((g) => g.isActive).toList();

  /// Categorías activas.
  List<FinanceCategory> get activeCategories =>
      categories.where((c) => c.isActive).toList();

  FinanceState copyWith({
    FinanceStatus? status,
    List<FinanceGroup>? groups,
    List<FinanceCategory>? categories,
    List<FinanceRecord>? records,
    List<FinanceUser>? companyUsers,
    String? filterGroupId,
    bool clearFilterGroupId = false,
    String? errorMessage,
  }) {
    return FinanceState(
      status: status ?? this.status,
      groups: groups ?? this.groups,
      categories: categories ?? this.categories,
      records: records ?? this.records,
      companyUsers: companyUsers ?? this.companyUsers,
      filterGroupId: clearFilterGroupId
          ? null
          : (filterGroupId ?? this.filterGroupId),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    groups,
    categories,
    records,
    companyUsers,
    filterGroupId,
    errorMessage,
  ];
}
