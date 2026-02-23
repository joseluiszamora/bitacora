import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/vehicle/vehicle_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/vehicle.dart';
import '../../../core/data/models/vehicle_document.dart';
import '../../../core/data/repositories/vehicle_document_repository.dart';
import 'vehicle_form_page.dart';

/// Página de detalle de un vehículo con sus documentos.
class VehicleDetailPage extends StatefulWidget {
  const VehicleDetailPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final _docRepository = VehicleDocumentRepository();
  List<VehicleDocument> _documents = [];
  bool _loadingDocs = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() => _loadingDocs = true);
    try {
      final docs = await _docRepository.getByVehicle(widget.vehicle.id);
      if (mounted) {
        setState(() {
          _documents = docs;
          _loadingDocs = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando documentos: $e');
      if (mounted) {
        setState(() => _loadingDocs = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final statusColor = switch (v.status) {
      VehicleStatus.active => AppColors.success,
      VehicleStatus.maintenance => AppColors.warning,
      VehicleStatus.inactive => AppColors.error,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(v.plateNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () {
              final bloc = context.read<VehicleBloc>();
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: VehicleFormPage(vehicle: v),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showAddDocumentDialog(),
        tooltip: 'Agregar Documento',
        child: const Icon(Icons.attach_file, color: AppColors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del vehículo
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Ícono grande
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(26),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          size: 48,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        v.plateNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 2,
                        ),
                      ),
                      if (v.displayName != v.plateNumber) ...[
                        const SizedBox(height: 4),
                        Text(
                          v.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Badge de estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withAlpha(128)),
                        ),
                        child: Text(
                          v.status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Datos del vehículo
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Vehículo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (v.company != null)
                        _DetailRow(label: 'Empresa', value: v.company!.name),
                      if (v.brand != null)
                        _DetailRow(label: 'Marca', value: v.brand!),
                      if (v.model != null)
                        _DetailRow(label: 'Modelo', value: v.model!),
                      if (v.year != null)
                        _DetailRow(label: 'Año', value: v.year.toString()),
                      if (v.color != null)
                        _DetailRow(label: 'Color', value: v.color!),
                      if (v.chasisCode != null)
                        _DetailRow(label: 'Chasis', value: v.chasisCode!),
                      if (v.motorCode != null)
                        _DetailRow(label: 'Motor', value: v.motorCode!),
                      if (v.ruatNumber != null)
                        _DetailRow(label: 'RUAT', value: v.ruatNumber!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fechas de vencimiento
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.grey.withAlpha(51)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fechas de Vencimiento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ExpirationRow(label: 'SOAT', date: v.soatExpirationDate),
                      _ExpirationRow(
                        label: 'Inspección Técnica',
                        date: v.inspectionExpirationDate,
                      ),
                      _ExpirationRow(
                        label: 'Seguro',
                        date: v.insuranceExpirationDate,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Documentos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Documentos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: _loadDocuments,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDocumentsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_loadingDocs) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_documents.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.grey.withAlpha(51)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.folder_open_outlined,
                  size: 48,
                  color: AppColors.grey.withAlpha(128),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No hay documentos registrados',
                  style: TextStyle(color: AppColors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: _documents
          .map(
            (doc) => _DocumentCard(
              document: doc,
              onDelete: () => _confirmDeleteDocument(doc),
            ),
          )
          .toList(),
    );
  }

  void _showAddDocumentDialog() {
    VehicleDocumentType selectedType = VehicleDocumentType.soat;
    DateTime? expirationDate;
    final urlController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar Documento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<VehicleDocumentType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Documento',
                    border: OutlineInputBorder(),
                  ),
                  items: VehicleDocumentType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL del Archivo',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    expirationDate != null
                        ? 'Vencimiento: ${expirationDate!.day.toString().padLeft(2, '0')}/${expirationDate!.month.toString().padLeft(2, '0')}/${expirationDate!.year}'
                        : 'Fecha de Vencimiento',
                  ),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => expirationDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await _docRepository.create(
                    vehicleId: widget.vehicle.id,
                    type: selectedType,
                    fileUrl: urlController.text.trim().isNotEmpty
                        ? urlController.text.trim()
                        : null,
                    expirationDate: expirationDate,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(this.context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text('Documento agregado con éxito.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    _loadDocuments();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(this.context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Error al agregar documento: $e'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                  }
                }
                urlController.dispose();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteDocument(VehicleDocument doc) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: Text(
          '¿Estás seguro de eliminar el documento "${doc.type.label}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await _docRepository.delete(doc.id);
                if (mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Documento eliminado.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  _loadDocuments();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('Error al eliminar: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Fila de detalle con label y valor.
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey.withAlpha(179),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.greyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de fecha de vencimiento con indicador de estado.
class _ExpirationRow extends StatelessWidget {
  const _ExpirationRow({required this.label, this.date});

  final String label;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    if (date == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.grey.withAlpha(179),
                ),
              ),
            ),
            const Text(
              'No registrado',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    final isExpired = date!.isBefore(DateTime.now());
    final isExpiringSoon =
        date!.isBefore(DateTime.now().add(const Duration(days: 30))) &&
        !isExpired;
    final color = isExpired
        ? AppColors.error
        : isExpiringSoon
        ? AppColors.warning
        : AppColors.success;

    final dateStr =
        '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}/${date!.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey.withAlpha(179),
              ),
            ),
          ),
          Icon(
            isExpired
                ? Icons.error
                : isExpiringSoon
                ? Icons.warning
                : Icons.check_circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            dateStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          if (isExpired)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Text(
                'Vencido',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tarjeta individual de documento de vehículo.
class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document, required this.onDelete});

  final VehicleDocument document;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = document.isExpired
        ? AppColors.error
        : document.isExpiringSoon
        ? AppColors.warning
        : AppColors.success;

    final docIcon = switch (document.type) {
      VehicleDocumentType.soat => Icons.health_and_safety_outlined,
      VehicleDocumentType.inspection => Icons.assignment_outlined,
      VehicleDocumentType.insurance => Icons.shield_outlined,
      VehicleDocumentType.ruat => Icons.article_outlined,
    };

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey.withAlpha(51)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(docIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.type.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  if (document.expirationDate != null)
                    Text(
                      'Vence: ${document.expirationDate!.day.toString().padLeft(2, '0')}/${document.expirationDate!.month.toString().padLeft(2, '0')}/${document.expirationDate!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            if (document.isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Vencido',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
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
    );
  }
}
