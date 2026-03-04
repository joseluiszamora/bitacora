import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/finance/finance_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/finance_category.dart';

/// Formulario para crear o editar una categoría financiera.
class FinanceCategoryFormPage extends StatefulWidget {
  const FinanceCategoryFormPage({super.key, this.category});

  final FinanceCategory? category;

  bool get isEditing => category != null;

  @override
  State<FinanceCategoryFormPage> createState() =>
      _FinanceCategoryFormPageState();
}

class _FinanceCategoryFormPageState extends State<FinanceCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    _isActive = widget.category?.isActive ?? true;
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
          title: Text(
            widget.isEditing ? 'Editar Categoría' : 'Nueva Categoría',
          ),
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
                        labelText: 'Nombre de la categoría *',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                        hintText:
                            'Ej: Pago por viaje, Impuestos, Reparaciones...',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el nombre de la categoría';
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
                        hintText: 'Descripción breve de la categoría',
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),

                    // Activa
                    if (widget.isEditing) ...[
                      SwitchListTile(
                        title: const Text('Categoría activa'),
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
        FinanceCategoryUpdateRequested(
          id: widget.category!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isActive: _isActive,
        ),
      );
    } else {
      context.read<FinanceBloc>().add(
        FinanceCategoryCreateRequested(
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
