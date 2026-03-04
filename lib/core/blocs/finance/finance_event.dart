part of 'finance_bloc.dart';

sealed class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

// ─── Carga ─────────────────────────────────────────────────────────────────

/// Cargar grupos, categorías y registros de la empresa.
final class FinanceLoadRequested extends FinanceEvent {
  const FinanceLoadRequested({required this.companyId});

  final String companyId;

  @override
  List<Object?> get props => [companyId];
}

// ─── Grupos ────────────────────────────────────────────────────────────────

/// Crear un nuevo grupo financiero.
final class FinanceGroupCreateRequested extends FinanceEvent {
  const FinanceGroupCreateRequested({
    required this.companyId,
    required this.name,
    this.description,
  });

  final String companyId;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [companyId, name, description];
}

/// Actualizar un grupo financiero.
final class FinanceGroupUpdateRequested extends FinanceEvent {
  const FinanceGroupUpdateRequested({
    required this.id,
    this.name,
    this.description,
    this.isActive,
  });

  final String id;
  final String? name;
  final String? description;
  final bool? isActive;

  @override
  List<Object?> get props => [id, name, description, isActive];
}

/// Eliminar un grupo financiero.
final class FinanceGroupDeleteRequested extends FinanceEvent {
  const FinanceGroupDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

// ─── Categorías ────────────────────────────────────────────────────────────

/// Crear una nueva categoría financiera.
final class FinanceCategoryCreateRequested extends FinanceEvent {
  const FinanceCategoryCreateRequested({
    required this.companyId,
    required this.name,
    this.description,
  });

  final String companyId;
  final String name;
  final String? description;

  @override
  List<Object?> get props => [companyId, name, description];
}

/// Actualizar una categoría financiera.
final class FinanceCategoryUpdateRequested extends FinanceEvent {
  const FinanceCategoryUpdateRequested({
    required this.id,
    this.name,
    this.description,
    this.isActive,
  });

  final String id;
  final String? name;
  final String? description;
  final bool? isActive;

  @override
  List<Object?> get props => [id, name, description, isActive];
}

/// Eliminar una categoría financiera.
final class FinanceCategoryDeleteRequested extends FinanceEvent {
  const FinanceCategoryDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

// ─── Registros ─────────────────────────────────────────────────────────────

/// Crear un nuevo registro/movimiento financiero.
final class FinanceRecordCreateRequested extends FinanceEvent {
  const FinanceRecordCreateRequested({
    required this.companyId,
    required this.groupId,
    required this.categoryId,
    required this.type,
    required this.amount,
    this.responsibleUserId,
    this.description,
    this.recordDate,
  });

  final String companyId;
  final String groupId;
  final String categoryId;
  final FinanceRecordType type;
  final double amount;
  final String? responsibleUserId;
  final String? description;
  final DateTime? recordDate;

  @override
  List<Object?> get props => [
    companyId,
    groupId,
    categoryId,
    type,
    amount,
    responsibleUserId,
    description,
    recordDate,
  ];
}

/// Actualizar un registro/movimiento financiero.
final class FinanceRecordUpdateRequested extends FinanceEvent {
  const FinanceRecordUpdateRequested({
    required this.id,
    this.groupId,
    this.categoryId,
    this.type,
    this.amount,
    this.responsibleUserId,
    this.description,
    this.recordDate,
  });

  final String id;
  final String? groupId;
  final String? categoryId;
  final FinanceRecordType? type;
  final double? amount;
  final String? responsibleUserId;
  final String? description;
  final DateTime? recordDate;

  @override
  List<Object?> get props => [
    id,
    groupId,
    categoryId,
    type,
    amount,
    responsibleUserId,
    description,
    recordDate,
  ];
}

/// Eliminar un registro/movimiento financiero.
final class FinanceRecordDeleteRequested extends FinanceEvent {
  const FinanceRecordDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

// ─── Filtros ───────────────────────────────────────────────────────────────

/// Filtrar registros por grupo.
final class FinanceFilterByGroupRequested extends FinanceEvent {
  const FinanceFilterByGroupRequested({this.groupId});

  final String? groupId;

  @override
  List<Object?> get props => [groupId];
}
