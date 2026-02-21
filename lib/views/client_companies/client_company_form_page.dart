import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/client_company/client_company_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/client_company.dart';

/// Formulario para crear o editar una empresa cliente.
class ClientCompanyFormPage extends StatefulWidget {
  const ClientCompanyFormPage({super.key, this.clientCompany});

  /// Si es `null`, se crea una nueva. Si tiene valor, se edita.
  final ClientCompany? clientCompany;

  bool get isEditing => clientCompany != null;

  @override
  State<ClientCompanyFormPage> createState() => _ClientCompanyFormPageState();
}

class _ClientCompanyFormPageState extends State<ClientCompanyFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nitController;
  late final TextEditingController _addressController;
  late final TextEditingController _contactEmailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.clientCompany?.name ?? '',
    );
    _nitController = TextEditingController(
      text: widget.clientCompany?.nit ?? '',
    );
    _addressController = TextEditingController(
      text: widget.clientCompany?.address ?? '',
    );
    _contactEmailController = TextEditingController(
      text: widget.clientCompany?.contactEmail ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nitController.dispose();
    _addressController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientCompanyBloc, ClientCompanyState>(
      listener: (context, state) {
        if (state.status == ClientCompanyStatus.success) {
          Navigator.of(context).pop();
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing
                ? 'Editar Empresa Cliente'
                : 'Nueva Empresa Cliente',
          ),
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
                      color: AppColors.gold.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront,
                      size: 36,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Nombre *
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Nombre *',
                      icon: Icons.business_outlined,
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

                  // NIT
                  TextFormField(
                    controller: _nitController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'NIT',
                      icon: Icons.numbers_outlined,
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Dirección
                  TextFormField(
                    controller: _addressController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Dirección',
                      icon: Icons.location_on_outlined,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Email de contacto
                  TextFormField(
                    controller: _contactEmailController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Email de contacto',
                      icon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Ingresa un correo electrónico válido.';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.marginBig),

                  // Botón guardar
                  BlocBuilder<ClientCompanyBloc, ClientCompanyState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == ClientCompanyStatus.creating ||
                          state.status == ClientCompanyStatus.updating;

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
                              ? 'Actualizar'
                              : 'Crear Empresa Cliente',
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

    final bloc = context.read<ClientCompanyBloc>();
    final name = _nameController.text.trim();
    final nit = _nitController.text.trim();
    final address = _addressController.text.trim();
    final contactEmail = _contactEmailController.text.trim();

    if (widget.isEditing) {
      bloc.add(
        ClientCompanyUpdateRequested(
          id: widget.clientCompany!.id,
          name: name,
          nit: nit.isNotEmpty ? nit : null,
          address: address.isNotEmpty ? address : null,
          contactEmail: contactEmail.isNotEmpty ? contactEmail : null,
        ),
      );
    } else {
      bloc.add(
        ClientCompanyCreateRequested(
          name: name,
          nit: nit.isNotEmpty ? nit : null,
          address: address.isNotEmpty ? address : null,
          contactEmail: contactEmail.isNotEmpty ? contactEmail : null,
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
