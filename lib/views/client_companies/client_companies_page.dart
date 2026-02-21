import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/client_company/client_company_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/client_company.dart';
import 'client_company_form_page.dart';

/// Página de administración de empresas cliente.
///
/// Accesible para `super_admin`.
class ClientCompaniesPage extends StatelessWidget {
  const ClientCompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ClientCompanyBloc()..add(const ClientCompanyLoadRequested()),
      child: const _ClientCompaniesView(),
    );
  }
}

class _ClientCompaniesView extends StatelessWidget {
  const _ClientCompaniesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () {
              context.read<ClientCompanyBloc>().add(
                const ClientCompanyLoadRequested(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add_business, color: AppColors.white),
      ),
      body: BlocConsumer<ClientCompanyBloc, ClientCompanyState>(
        listener: (context, state) {
          if (state.status == ClientCompanyStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Operación realizada con éxito.'),
                  backgroundColor: AppColors.success,
                ),
              );
          }
          if (state.status == ClientCompanyStatus.failure &&
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
          if (state.status == ClientCompanyStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.clientCompanies.isEmpty &&
              state.status != ClientCompanyStatus.loading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: AppColors.grey.withAlpha(128),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay empresas cliente registradas',
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
              context.read<ClientCompanyBloc>().add(
                const ClientCompanyLoadRequested(),
              );
              await context.read<ClientCompanyBloc>().stream.firstWhere(
                (s) => s.status != ClientCompanyStatus.loading,
              );
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppDefaults.padding),
              itemCount: state.clientCompanies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cc = state.clientCompanies[index];
                return _ClientCompanyCard(
                  clientCompany: cc,
                  onEdit: () => _navigateToForm(context, clientCompany: cc),
                  onDelete: () => _confirmDelete(context, cc),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context, {ClientCompany? clientCompany}) {
    final bloc = context.read<ClientCompanyBloc>();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ClientCompanyFormPage(clientCompany: clientCompany),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ClientCompany cc) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Empresa Cliente'),
        content: Text(
          '¿Estás seguro de eliminar "${cc.name}"?\n\n'
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
              context.read<ClientCompanyBloc>().add(
                ClientCompanyDeleteRequested(cc.id),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de empresa cliente
// ─────────────────────────────────────────────────────────────────────────────

class _ClientCompanyCard extends StatelessWidget {
  const _ClientCompanyCard({
    required this.clientCompany,
    required this.onEdit,
    required this.onDelete,
  });

  final ClientCompany clientCompany;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientCompany.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    if (clientCompany.nit != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'NIT: ${clientCompany.nit}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                    if (clientCompany.contactEmail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        clientCompany.contactEmail!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey.withAlpha(179),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
