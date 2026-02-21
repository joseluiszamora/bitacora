import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/company/company_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/company.dart';
import 'company_form_page.dart';

/// Página de listado de compañías — CRUD para super_admin.
class CompaniesPage extends StatelessWidget {
  const CompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyBloc()..add(const CompanyLoadRequested()),
      child: const _CompaniesView(),
    );
  }
}

class _CompaniesView extends StatelessWidget {
  const _CompaniesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compañías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<CompanyBloc>().add(const CompanyLoadRequested());
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: BlocConsumer<CompanyBloc, CompanyState>(
        listener: (context, state) {
          if (state.status == CompanyStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == CompanyStatus.failure &&
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
          if (state.status == CompanyStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.companies.isEmpty &&
              state.status != CompanyStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay compañías registradas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Toca el botón + para agregar la primera.',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CompanyBloc>().add(const CompanyLoadRequested());
              // Esperar a que cambie de loading a otro estado
              await context.read<CompanyBloc>().stream.firstWhere(
                (s) => s.status != CompanyStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.companies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final company = state.companies[index];
                return _CompanyCard(
                  company: company,
                  onEdit: () => _navigateToForm(context, company: company),
                  onDelete: () => _confirmDelete(context, company),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Company? company}) {
    final bloc = context.read<CompanyBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CompanyFormPage(company: company),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Company company) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Compañía'),
        content: Text(
          '¿Estás seguro de eliminar "${company.name}"?\n\n'
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
              context.read<CompanyBloc>().add(
                CompanyDeleteRequested(company.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de compañía.
class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.company,
    required this.onEdit,
    required this.onDelete,
  });

  final Company company;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isActive = company.status == 'active';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícono
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.primary : AppColors.grey)
                      .withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.business,
                  color: isActive ? AppColors.primary : AppColors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isActive ? AppColors.primary : AppColors.grey,
                      ),
                    ),
                    if (company.socialReason != null &&
                        company.socialReason!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          company.socialReason!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    if (company.nit != null && company.nit!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'NIT: ${company.nit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey.withAlpha(179),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Estado badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? AppColors.success : AppColors.error)
                      .withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Activa' : 'Inactiva',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.success : AppColors.error,
                  ),
                ),
              ),

              // Botón eliminar
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error.withAlpha(179),
                  size: 20,
                ),
                tooltip: 'Eliminar',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
