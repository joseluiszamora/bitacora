import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/client_location/client_location_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/client_location.dart';
import 'client_location_form_page.dart';

/// Detalle de una ubicación de cliente.
class ClientLocationDetailPage extends StatelessWidget {
  const ClientLocationDetailPage({super.key, required this.location});

  final ClientLocation location;

  @override
  Widget build(BuildContext context) {
    IconData typeIcon;
    switch (location.type) {
      case ClientLocationType.warehouse:
        typeIcon = Icons.warehouse;
      case ClientLocationType.distributionCenter:
        typeIcon = Icons.local_shipping;
      case ClientLocationType.office:
        typeIcon = Icons.business;
      case ClientLocationType.plant:
        typeIcon = Icons.factory;
    }

    final isActive = location.status == ClientLocationStatus.active;
    final statusColor = isActive ? AppColors.success : AppColors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => _navigateToEdit(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado con ícono de tipo y estado
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(typeIcon, color: AppColors.primary, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      location.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location.type.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withAlpha(128)),
                      ),
                      child: Text(
                        location.status.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDefaults.marginMedium),

              // Empresa cliente
              if (location.clientCompany != null)
                _DetailCard(
                  icon: Icons.storefront,
                  title: 'Empresa Cliente',
                  value: location.clientCompany!.name,
                ),
              const SizedBox(height: AppDefaults.margin),

              // Dirección
              if (location.address != null && location.address!.isNotEmpty)
                _DetailRow(
                  icon: Icons.location_on,
                  label: 'Dirección',
                  value: location.address!,
                ),

              // Ciudad
              if (location.city != null)
                _DetailRow(
                  icon: Icons.location_city,
                  label: 'Ciudad',
                  value: location.city!.displayName,
                ),

              // País
              _DetailRow(
                icon: Icons.flag,
                label: 'País',
                value: location.country,
              ),

              // Coordenadas
              if (location.latitude != null && location.longitude != null)
                _DetailRow(
                  icon: Icons.explore,
                  label: 'Coordenadas',
                  value:
                      '${location.latitude!.toStringAsFixed(6)}, ${location.longitude!.toStringAsFixed(6)}',
                ),

              // Contacto
              if (location.contactName != null &&
                  location.contactName!.isNotEmpty)
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Contacto',
                  value: location.contactName!,
                ),

              if (location.contactPhone != null &&
                  location.contactPhone!.isNotEmpty)
                _DetailRow(
                  icon: Icons.phone,
                  label: 'Teléfono',
                  value: location.contactPhone!,
                ),

              // Creado
              if (location.createdAt != null)
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Creado el',
                  value: _formatDateTime(location.createdAt!),
                ),

              const SizedBox(height: AppDefaults.marginBig),

              // Eliminar
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar Ubicación'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    final bloc = context.read<ClientLocationBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: ClientLocationFormPage(location: location),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Ubicación'),
        content: Text(
          '¿Estás seguro de eliminar "${location.name}"?\n\n'
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
              context.read<ClientLocationBloc>().add(
                ClientLocationDeleteRequested(location.id),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

/// Tarjeta de detalle con icono.
class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de detalle simple.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey.withAlpha(179)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
