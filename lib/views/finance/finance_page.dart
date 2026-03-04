import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/finance/finance_bloc.dart';
import '../../core/blocs/service_locator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/finance_category.dart';
import '../../core/data/models/finance_group.dart';
import '../../core/data/models/finance_record.dart';
import 'finance_category_form_page.dart';
import 'finance_group_form_page.dart';
import 'finance_record_form_page.dart';

/// Página principal del módulo de Finanzas.
///
/// Contiene 3 tabs: Movimientos, Grupos y Categorías.
/// Accesible para super_admin, admin y supervisor.
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    final companyId = authState.user.company.id;

    return BlocProvider(
      create: (_) =>
          getIt<FinanceBloc>()..add(FinanceLoadRequested(companyId: companyId)),
      child: const _FinanceView(),
    );
  }
}

class _FinanceView extends StatelessWidget {
  const _FinanceView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Finanzas'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () {
                final companyId = context
                    .read<AuthenticationBloc>()
                    .state
                    .user
                    .company
                    .id;
                context.read<FinanceBloc>().add(
                  FinanceLoadRequested(companyId: companyId),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.swap_vert), text: 'Movimientos'),
              Tab(icon: Icon(Icons.folder_outlined), text: 'Grupos'),
              Tab(icon: Icon(Icons.category_outlined), text: 'Categorías'),
            ],
          ),
        ),
        body: BlocConsumer<FinanceBloc, FinanceState>(
          listener: (context, state) {
            if (state.status == FinanceStatus.success) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Operación realizada con éxito.'),
                    backgroundColor: AppColors.success,
                  ),
                );
            }
            if (state.status == FinanceStatus.failure &&
                state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: AppColors.error,
                  ),
                );
            }
          },
          builder: (context, state) {
            if (state.status == FinanceStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return const TabBarView(
              children: [_RecordsTab(), _GroupsTab(), _CategoriesTab()],
            );
          },
        ),
      ),
    );
  }
}

// ─── Tab: Movimientos ────────────────────────────────────────────────────────

class _RecordsTab extends StatelessWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        return Stack(
          children: [
            Column(
              children: [
                // Resumen financiero
                _FinanceSummary(
                  income: state.totalIncome,
                  expense: state.totalExpense,
                  balance: state.balance,
                ),

                // Filtro por grupo
                _GroupFilter(
                  groups: state.groups,
                  selectedGroupId: state.filterGroupId,
                  onChanged: (groupId) {
                    context.read<FinanceBloc>().add(
                      FinanceFilterByGroupRequested(groupId: groupId),
                    );
                  },
                ),

                // Lista de movimientos
                Expanded(
                  child: state.filteredRecords.isEmpty
                      ? _buildEmpty(
                          icon: Icons.swap_vert,
                          message: 'No hay movimientos registrados',
                          subtitle:
                              'Toca el botón + para registrar un ingreso o egreso.',
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            final companyId = context
                                .read<AuthenticationBloc>()
                                .state
                                .user
                                .company
                                .id;
                            context.read<FinanceBloc>().add(
                              FinanceLoadRequested(companyId: companyId),
                            );
                            await context.read<FinanceBloc>().stream.firstWhere(
                              (s) => s.status != FinanceStatus.loading,
                            );
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppDefaults.padding),
                            itemCount: state.filteredRecords.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final record = state.filteredRecords[index];
                              return _RecordCard(
                                record: record,
                                groups: state.groups,
                                categories: state.categories,
                                onEdit: () => _navigateToRecordForm(
                                  context,
                                  record: record,
                                ),
                                onDelete: () =>
                                    _confirmDeleteRecord(context, record),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'fab_record',
                backgroundColor: AppColors.primary,
                onPressed: () => _navigateToRecordForm(context),
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            ),
          ],
        );
      },
      buildWhen: (previous, current) =>
          previous.filteredRecords != current.filteredRecords ||
          previous.totalIncome != current.totalIncome ||
          previous.totalExpense != current.totalExpense ||
          previous.filterGroupId != current.filterGroupId ||
          previous.groups != current.groups,
    );
  }

  void _navigateToRecordForm(BuildContext context, {FinanceRecord? record}) {
    final bloc = context.read<FinanceBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: FinanceRecordFormPage(record: record),
        ),
      ),
    );
  }

  void _confirmDeleteRecord(BuildContext context, FinanceRecord record) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Movimiento'),
        content: Text(
          '¿Eliminar este ${record.type.label.toLowerCase()} '
          'de Bs. ${record.amount.toStringAsFixed(2)}?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FinanceBloc>().add(
                FinanceRecordDeleteRequested(record.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Grupos ─────────────────────────────────────────────────────────────

class _GroupsTab extends StatelessWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      buildWhen: (previous, current) => previous.groups != current.groups,
      builder: (context, state) {
        return Stack(
          children: [
            if (state.groups.isEmpty)
              _buildEmptyWithAction(
                icon: Icons.folder_outlined,
                message: 'No hay grupos registrados',
                subtitle:
                    'Crea grupos para organizar tus movimientos financieros.',
                actionLabel: 'Crear Grupo',
                onAction: () => _navigateToGroupForm(context),
              )
            else
              RefreshIndicator(
                onRefresh: () async {
                  final companyId = context
                      .read<AuthenticationBloc>()
                      .state
                      .user
                      .company
                      .id;
                  context.read<FinanceBloc>().add(
                    FinanceLoadRequested(companyId: companyId),
                  );
                  await context.read<FinanceBloc>().stream.firstWhere(
                    (s) => s.status != FinanceStatus.loading,
                  );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  itemCount: state.groups.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final group = state.groups[index];
                    return _GroupCard(
                      group: group,
                      onEdit: () => _navigateToGroupForm(context, group: group),
                      onToggleActive: () {
                        context.read<FinanceBloc>().add(
                          FinanceGroupUpdateRequested(
                            id: group.id,
                            isActive: !group.isActive,
                          ),
                        );
                      },
                      onDelete: () => _confirmDeleteGroup(context, group),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'fab_group',
                backgroundColor: AppColors.primary,
                onPressed: () => _navigateToGroupForm(context),
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToGroupForm(BuildContext context, {FinanceGroup? group}) {
    final bloc = context.read<FinanceBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: FinanceGroupFormPage(group: group),
        ),
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, FinanceGroup group) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Grupo'),
        content: Text(
          '¿Eliminar "${group.name}"?\n\n'
          'Si tiene movimientos asociados, se recomienda desactivarlo '
          'en lugar de eliminarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FinanceBloc>().add(
                FinanceGroupDeleteRequested(group.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Tab: Categorías ─────────────────────────────────────────────────────────

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories,
      builder: (context, state) {
        return Stack(
          children: [
            if (state.categories.isEmpty)
              _buildEmptyWithAction(
                icon: Icons.category_outlined,
                message: 'No hay categorías registradas',
                subtitle:
                    'Crea categorías como "Pago por viaje", "Impuestos", etc.',
                actionLabel: 'Crear Categoría',
                onAction: () => _navigateToCategoryForm(context),
              )
            else
              RefreshIndicator(
                onRefresh: () async {
                  final companyId = context
                      .read<AuthenticationBloc>()
                      .state
                      .user
                      .company
                      .id;
                  context.read<FinanceBloc>().add(
                    FinanceLoadRequested(companyId: companyId),
                  );
                  await context.read<FinanceBloc>().stream.firstWhere(
                    (s) => s.status != FinanceStatus.loading,
                  );
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  itemCount: state.categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return _CategoryCard(
                      category: category,
                      onEdit: () =>
                          _navigateToCategoryForm(context, category: category),
                      onToggleActive: () {
                        context.read<FinanceBloc>().add(
                          FinanceCategoryUpdateRequested(
                            id: category.id,
                            isActive: !category.isActive,
                          ),
                        );
                      },
                      onDelete: () => _confirmDeleteCategory(context, category),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'fab_category',
                backgroundColor: AppColors.primary,
                onPressed: () => _navigateToCategoryForm(context),
                child: const Icon(Icons.add, color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCategoryForm(
    BuildContext context, {
    FinanceCategory? category,
  }) {
    final bloc = context.read<FinanceBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: FinanceCategoryFormPage(category: category),
        ),
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, FinanceCategory category) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
          '¿Eliminar "${category.name}"?\n\n'
          'Si tiene movimientos asociados, se recomienda desactivarla '
          'en lugar de eliminarla.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<FinanceBloc>().add(
                FinanceCategoryDeleteRequested(category.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets compartidos ─────────────────────────────────────────────────────

Widget _buildEmpty({
  required IconData icon,
  required String message,
  required String subtitle,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppDefaults.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.grey.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    ),
  );
}

/// Estado vacío con botón de acción para crear el primer registro.
Widget _buildEmptyWithAction({
  required IconData icon,
  required String message,
  required String subtitle,
  required String actionLabel,
  required VoidCallback onAction,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(AppDefaults.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppColors.grey.withAlpha(128)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Resumen financiero: ingresos, egresos y balance.
class _FinanceSummary extends StatelessWidget {
  const _FinanceSummary({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppDefaults.padding),
      padding: const EdgeInsets.all(AppDefaults.cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDefaults.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(51),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Balance
          Text(
            'Balance',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withAlpha(179),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Bs. ${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: balance >= 0 ? AppColors.white : AppColors.goldSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.trending_up,
                  label: 'Ingresos',
                  amount: income,
                  color: const Color(0xFF4ADE80),
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: AppColors.white.withAlpha(51),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.trending_down,
                  label: 'Egresos',
                  amount: expense,
                  color: const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.white.withAlpha(179)),
        ),
        const SizedBox(height: 2),
        Text(
          'Bs. ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Filtro por grupo en la pestaña de movimientos.
class _GroupFilter extends StatelessWidget {
  const _GroupFilter({
    required this.groups,
    required this.selectedGroupId,
    required this.onChanged,
  });

  final List<FinanceGroup> groups;
  final String? selectedGroupId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDefaults.padding),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Filtrar por grupo',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDefaults.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          isDense: true,
          prefixIcon: const Icon(Icons.filter_list, size: 20),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedGroupId,
            isExpanded: true,
            isDense: true,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos los grupos', style: TextStyle(fontSize: 13)),
              ),
              ...groups.map(
                (group) => DropdownMenuItem<String>(
                  value: group.id,
                  child: Row(
                    children: [
                      Icon(
                        group.isActive
                            ? Icons.folder
                            : Icons.folder_off_outlined,
                        size: 16,
                        color: group.isActive
                            ? AppColors.gold
                            : AppColors.grey.withAlpha(128),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          group.name,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (id) => onChanged(id),
          ),
        ),
      ),
    );
  }
}

// ─── Tarjetas ────────────────────────────────────────────────────────────────

/// Tarjeta de movimiento financiero.
class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.groups,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final FinanceRecord record;
  final List<FinanceGroup> groups;
  final List<FinanceCategory> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = record.isIncome;
    final color = isIncome ? AppColors.success : AppColors.error;
    final groupName =
        record.group?.name ??
        groups
            .cast<FinanceGroup?>()
            .firstWhere((g) => g!.id == record.groupId, orElse: () => null)
            ?.name ??
        'Sin grupo';
    final categoryName =
        record.category?.name ??
        categories
            .cast<FinanceCategory?>()
            .firstWhere((c) => c!.id == record.categoryId, orElse: () => null)
            ?.name ??
        'Sin categoría';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withAlpha(51)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(AppDefaults.cardPadding),
          child: Row(
            children: [
              // Ícono tipo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 12,
                          color: AppColors.grey.withAlpha(153),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            groupName,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grey.withAlpha(153),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (record.description != null &&
                        record.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        record.description!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey.withAlpha(153),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Monto y fecha
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} Bs. ${record.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  if (record.recordDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(record.recordDate!),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey.withAlpha(153),
                      ),
                    ),
                  ],
                ],
              ),

              // Menú
              PopupMenuButton<String>(
                iconSize: 20,
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Eliminar',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d/$m/$y';
  }
}

/// Tarjeta de grupo financiero.
class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final FinanceGroup group;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: group.isActive
                ? AppColors.gold.withAlpha(26)
                : AppColors.grey.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            group.isActive ? Icons.folder : Icons.folder_off_outlined,
            color: group.isActive ? AppColors.gold : AppColors.grey,
            size: 22,
          ),
        ),
        title: Text(
          group.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: group.isActive ? null : AppColors.grey.withAlpha(153),
            decoration: group.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: group.description != null && group.description!.isNotEmpty
            ? Text(
                group.description!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge activo/inactivo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: group.isActive
                    ? AppColors.success.withAlpha(26)
                    : AppColors.grey.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: group.isActive
                      ? AppColors.success.withAlpha(128)
                      : AppColors.grey.withAlpha(128),
                ),
              ),
              child: Text(
                group.isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: group.isActive ? AppColors.success : AppColors.grey,
                ),
              ),
            ),
            PopupMenuButton<String>(
              iconSize: 20,
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'toggle') onToggleActive();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        group.isActive ? Icons.toggle_off : Icons.toggle_on,
                        size: 18,
                        color: group.isActive
                            ? AppColors.grey
                            : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(group.isActive ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de categoría financiera.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final FinanceCategory category;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: ListTile(
        onTap: onEdit,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.isActive
                ? AppColors.primaryAccent.withAlpha(26)
                : AppColors.grey.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            category.isActive ? Icons.category : Icons.category_outlined,
            color: category.isActive ? AppColors.primaryAccent : AppColors.grey,
            size: 22,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: category.isActive ? null : AppColors.grey.withAlpha(153),
            decoration: category.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle:
            category.description != null && category.description!.isNotEmpty
            ? Text(
                category.description!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: category.isActive
                    ? AppColors.success.withAlpha(26)
                    : AppColors.grey.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: category.isActive
                      ? AppColors.success.withAlpha(128)
                      : AppColors.grey.withAlpha(128),
                ),
              ),
              child: Text(
                category.isActive ? 'Activa' : 'Inactiva',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: category.isActive ? AppColors.success : AppColors.grey,
                ),
              ),
            ),
            PopupMenuButton<String>(
              iconSize: 20,
              padding: EdgeInsets.zero,
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'toggle') onToggleActive();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        category.isActive ? Icons.toggle_off : Icons.toggle_on,
                        size: 18,
                        color: category.isActive
                            ? AppColors.grey
                            : AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(category.isActive ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
