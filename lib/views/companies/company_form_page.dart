import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/company/company_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/company.dart';

/// Formulario para crear o editar una compañía.
class CompanyFormPage extends StatefulWidget {
  const CompanyFormPage({super.key, this.company});

  /// Si es null, se crea una nueva compañía. Si tiene valor, se edita.
  final Company? company;

  bool get isEditing => company != null;

  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _socialReasonController;
  late final TextEditingController _nitController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _socialReasonController = TextEditingController(
      text: widget.company?.socialReason ?? '',
    );
    _nitController = TextEditingController(text: widget.company?.nit ?? '');
    _status = widget.company?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _socialReasonController.dispose();
    _nitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyBloc, CompanyState>(
      listener: (context, state) {
        if (state.status == CompanyStatus.success) {
          Navigator.of(context).pop();
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Editar Compañía' : 'Nueva Compañía'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDefaults.margin),

                  // Ícono decorativo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Nombre *
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Nombre de la compañía *',
                      icon: Icons.business_center_outlined,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio.';
                      }
                      if (value.trim().length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Razón Social
                  TextFormField(
                    controller: _socialReasonController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Razón Social',
                      icon: Icons.description_outlined,
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // NIT
                  TextFormField(
                    controller: _nitController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'NIT',
                      icon: Icons.numbers,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Estado (solo en edición)
                  if (widget.isEditing) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: _inputDecoration(
                        label: 'Estado',
                        icon: Icons.toggle_on_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Activa'),
                        ),
                        DropdownMenuItem(
                          value: 'inactive',
                          child: Text('Inactiva'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: AppDefaults.margin),
                  ],

                  const SizedBox(height: AppDefaults.marginMedium),

                  // Botón guardar
                  BlocBuilder<CompanyBloc, CompanyState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == CompanyStatus.creating ||
                          state.status == CompanyStatus.updating;

                      return FilledButton.icon(
                        onPressed: isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDefaults.radius,
                            ),
                          ),
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          isLoading
                              ? 'Guardando...'
                              : widget.isEditing
                              ? 'Actualizar Compañía'
                              : 'Crear Compañía',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<CompanyBloc>();
    final name = _nameController.text.trim();
    final socialReason = _socialReasonController.text.trim();
    final nit = _nitController.text.trim();

    if (widget.isEditing) {
      bloc.add(
        CompanyUpdateRequested(
          id: widget.company!.id,
          name: name,
          socialReason: socialReason.isNotEmpty ? socialReason : null,
          nit: nit.isNotEmpty ? nit : null,
          status: _status,
        ),
      );
    } else {
      bloc.add(
        CompanyCreateRequested(
          name: name,
          socialReason: socialReason.isNotEmpty ? socialReason : null,
          nit: nit.isNotEmpty ? nit : null,
        ),
      );
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        borderSide: BorderSide(color: AppColors.grey.withAlpha(77)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        borderSide: BorderSide(color: AppColors.grey.withAlpha(77)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radius),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
