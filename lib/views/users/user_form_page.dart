import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/company/company_bloc.dart';
import '../../core/blocs/user_management/user_management_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/company.dart';
import '../../core/data/models/user.dart';
import '../../core/data/models/user_role.dart';

/// Formulario para crear o editar un usuario.
///
/// Requiere el rol del usuario autenticado para filtrar los roles asignables
/// y, opcionalmente, el `companyId` del admin para fijarlo.
class UserFormPage extends StatefulWidget {
  const UserFormPage({
    super.key,
    this.user,
    required this.currentUserRole,
    this.currentUserCompanyId,
  });

  /// Si es `null`, se crea un nuevo usuario. Si tiene valor, se edita.
  final User? user;

  /// Rol del usuario autenticado (para filtrar roles asignables).
  final UserRole currentUserRole;

  /// Company ID del usuario autenticado (para fijar empresa si es admin).
  final String? currentUserCompanyId;

  bool get isEditing => user != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;

  late UserRole _selectedRole;
  String? _selectedCompanyId;

  /// Roles que el usuario actual puede asignar.
  late List<UserRole> _assignableRoles;

  /// Lista de compañías para el dropdown.
  List<Company> _companies = [];
  bool _loadingCompanies = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');

    // Roles asignables según el usuario actual
    _assignableRoles = _getAssignableRoles(widget.currentUserRole);

    // Rol inicial
    if (widget.isEditing && _assignableRoles.contains(widget.user!.role)) {
      _selectedRole = widget.user!.role;
    } else {
      _selectedRole = _assignableRoles.isNotEmpty
          ? _assignableRoles.first
          : UserRole.driver;
    }

    // Company
    if (widget.currentUserRole == UserRole.admin) {
      // Admin solo puede asignar a su propia compañía
      _selectedCompanyId = widget.currentUserCompanyId;
      _loadingCompanies = false;
    } else {
      _selectedCompanyId = widget.user?.company.id;
    }

    // Cargar compañías para super_admin
    if (widget.currentUserRole == UserRole.superAdmin) {
      _loadCompanies();
    }
  }

  /// Roles que un usuario puede asignar según su rol actual.
  List<UserRole> _getAssignableRoles(UserRole currentRole) {
    if (currentRole == UserRole.superAdmin) {
      return [
        UserRole.admin,
        UserRole.supervisor,
        UserRole.driver,
        UserRole.finance,
      ];
    }
    if (currentRole == UserRole.admin) {
      return [UserRole.supervisor, UserRole.driver, UserRole.finance];
    }
    return [];
  }

  Future<void> _loadCompanies() async {
    try {
      final companyBloc = CompanyBloc()..add(const CompanyLoadRequested());
      final state = await companyBloc.stream.firstWhere(
        (s) =>
            s.status == CompanyStatus.loaded ||
            s.status == CompanyStatus.failure,
      );

      if (mounted) {
        setState(() {
          _companies = state.companies;
          _loadingCompanies = false;
        });
      }

      await companyBloc.close();
    } catch (_) {
      if (mounted) setState(() => _loadingCompanies = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state.status == UserManagementStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.status == UserManagementStatus.failure &&
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
          title: Text(widget.isEditing ? 'Editar Usuario' : 'Nuevo Usuario'),
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
                      Icons.person,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Nombre completo *
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Nombre completo *',
                      icon: Icons.person_outline,
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

                  // Email * (solo creación)
                  if (!widget.isEditing) ...[
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: AppColors.greyDark),
                      decoration: _inputDecoration(
                        label: 'Correo electrónico *',
                        icon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo electrónico es obligatorio.';
                        }
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Ingresa un correo electrónico válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDefaults.margin),
                  ],

                  // Contraseña * (solo creación)
                  if (!widget.isEditing) ...[
                    TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(color: AppColors.greyDark),
                      decoration: _inputDecoration(
                        label: 'Contraseña *',
                        icon: Icons.lock_outline,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La contraseña es obligatoria.';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDefaults.margin),
                  ],

                  // Teléfono
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Teléfono',
                      icon: Icons.phone_outlined,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Rol *
                  DropdownButtonFormField<UserRole>(
                    initialValue: _selectedRole,
                    decoration: _inputDecoration(
                      label: 'Rol *',
                      icon: Icons.admin_panel_settings_outlined,
                    ),
                    items: _assignableRoles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedRole = value);
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un rol.';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Compañía (super_admin elige, admin se fija)
                  if (widget.currentUserRole == UserRole.superAdmin) ...[
                    if (_loadingCompanies)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue:
                            _selectedCompanyId != null &&
                                _companies.any(
                                  (c) => c.id == _selectedCompanyId,
                                )
                            ? _selectedCompanyId
                            : null,
                        decoration: _inputDecoration(
                          label: 'Compañía',
                          icon: Icons.business_outlined,
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sin compañía'),
                          ),
                          ..._companies.map((company) {
                            return DropdownMenuItem(
                              value: company.id,
                              child: Text(company.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCompanyId = value);
                        },
                      ),
                    const SizedBox(height: AppDefaults.margin),
                  ],

                  const SizedBox(height: AppDefaults.marginMedium),

                  // Botón guardar
                  BlocBuilder<UserManagementBloc, UserManagementState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == UserManagementStatus.creating ||
                          state.status == UserManagementStatus.updating;

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
                              ? 'Actualizar Usuario'
                              : 'Crear Usuario',
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

    final bloc = context.read<UserManagementBloc>();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (widget.isEditing) {
      bloc.add(
        UserManagementUpdateRequested(
          userId: widget.user!.id,
          fullName: name,
          role: _selectedRole.value,
          companyId: _selectedCompanyId,
          phone: phone.isNotEmpty ? phone : null,
        ),
      );
    } else {
      bloc.add(
        UserManagementCreateRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: name,
          role: _selectedRole,
          companyId: _selectedCompanyId,
          phone: phone.isNotEmpty ? phone : null,
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
