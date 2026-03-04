import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/finance/finance_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/finance_group.dart';

/// Formulario para crear o editar un grupo financiero.
class FinanceGroupFormPage extends StatefulWidget {
  const FinanceGroupFormPage({super.key, this.group});

  final FinanceGroup? group;

  bool get isEditing => group != null;

  @override
  State<FinanceGroupFormPage> createState() => _FinanceGroupFormPageState();
}

class _FinanceGroupFormPageState extends State<FinanceGroupFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.group?.description ?? '',
    );
    _isActive = widget.group?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state.status == FinanceStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Editar Grupo' : 'Nuevo Grupo'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Form(
            key: _formKey,
            child: BlocBuilder<FinanceBloc, FinanceState>(
              buildWhen: (prev, curr) => prev.status != curr.status,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del grupo *',
                        prefixIcon: Icon(Icons.folder_outlined),
                        border: OutlineInputBorder(),
                        hintText: 'Ej: Gastos de enero, Reparación vehículo...',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el nombre del grupo';
                        }
                        if (value.trim().length < 3) {
                          return 'El nombre debe tener al menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                        hintText: 'Descripción breve del grupo',
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),

                    // Activo
                    if (widget.isEditing) ...[
                      SwitchListTile(
                        title: const Text('Grupo activo'),
                        subtitle: Text(
                          _isActive
                              ? 'Visible al registrar movimientos'
                              : 'No aparecerá al crear movimientos',
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: _isActive,
                        activeTrackColor: AppColors.success,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(() => _isActive = value),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Botón guardar
                    FilledButton.icon(
                      onPressed:
                          state.status == FinanceStatus.creating ||
                              state.status == FinanceStatus.updating
                          ? null
                          : _onSubmit,
                      icon:
                          state.status == FinanceStatus.creating ||
                              state.status == FinanceStatus.updating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(widget.isEditing ? 'Actualizar' : 'Guardar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final companyId = context.read<AuthenticationBloc>().state.user.company.id;

    if (widget.isEditing) {
      context.read<FinanceBloc>().add(
        FinanceGroupUpdateRequested(
          id: widget.group!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isActive: _isActive,
        ),
      );
    } else {
      context.read<FinanceBloc>().add(
        FinanceGroupCreateRequested(
          companyId: companyId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        ),
      );
    }
  }
}
