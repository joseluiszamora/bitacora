import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/client_location/client_location_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/city.dart';
import '../../core/data/models/client_company.dart';
import '../../core/data/models/client_location.dart';
import '../../core/data/models/user_role.dart';
import '../../core/data/repositories/city_repository.dart';
import '../../core/data/repositories/client_company_repository.dart';

/// Formulario para crear o editar una ubicación de cliente.
class ClientLocationFormPage extends StatefulWidget {
  const ClientLocationFormPage({
    super.key,
    this.location,
    this.clientCompanyId,
  });

  /// Si es null, se crea nueva. Si tiene valor, se edita.
  final ClientLocation? location;

  /// Pre-seleccionar la empresa cliente (cuando se navega desde una empresa).
  final String? clientCompanyId;

  bool get isEditing => location != null;

  @override
  State<ClientLocationFormPage> createState() => _ClientLocationFormPageState();
}

class _ClientLocationFormPageState extends State<ClientLocationFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _countryController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactPhoneController;

  String? _clientCompanyId;
  ClientLocationType _type = ClientLocationType.warehouse;
  String? _cityId;
  ClientLocationStatus _status = ClientLocationStatus.active;

  bool _loadingCities = true;
  bool _loadingCompanies = true;
  List<City> _cities = [];
  List<ClientCompany> _clientCompanies = [];

  @override
  void initState() {
    super.initState();
    final loc = widget.location;

    _nameController = TextEditingController(text: loc?.name ?? '');
    _addressController = TextEditingController(text: loc?.address ?? '');
    _countryController = TextEditingController(text: loc?.country ?? 'Bolivia');
    _latitudeController = TextEditingController(
      text: loc?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: loc?.longitude?.toString() ?? '',
    );
    _contactNameController = TextEditingController(
      text: loc?.contactName ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: loc?.contactPhone ?? '',
    );

    _clientCompanyId = loc?.clientCompanyId ?? widget.clientCompanyId;
    _type = loc?.type ?? ClientLocationType.warehouse;
    _cityId = loc?.cityId;
    _status = loc?.status ?? ClientLocationStatus.active;

    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Capturar referencia antes de async gap
    final authState = context.read<AuthenticationBloc>().state;
    final isSuperAdmin = authState.user.role == UserRole.superAdmin;

    // Cargar ciudades
    try {
      final cityRepo = GetIt.instance<CityRepository>();
      _cities = await cityRepo.getAll();
    } catch (e) {
      _cities = [];
    }
    if (mounted) setState(() => _loadingCities = false);

    // Cargar empresas cliente
    try {
      final ccRepo = GetIt.instance<ClientCompanyRepository>();
      if (isSuperAdmin) {
        _clientCompanies = await ccRepo.getAll();
      } else {
        // Para otros roles, mostrar solo las relevantes
        _clientCompanies = await ccRepo.getAll();
      }
    } catch (e) {
      _clientCompanies = [];
    }
    if (mounted) setState(() => _loadingCompanies = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return BlocListener<ClientLocationBloc, ClientLocationState>(
      listener: (context, state) {
        if (state.status == ClientLocationBlocStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar Ubicación' : 'Nueva Ubicación'),
        ),
        body: _loadingCities || _loadingCompanies
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Empresa cliente
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Empresa Cliente *',
                            prefixIcon: Icon(Icons.storefront),
                          ),
                          initialValue: _clientCompanyId,
                          items: _clientCompanies
                              .map(
                                (cc) => DropdownMenuItem(
                                  value: cc.id,
                                  child: Text(
                                    cc.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecciona una empresa cliente.';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              setState(() => _clientCompanyId = value),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Nombre
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre *',
                            prefixIcon: Icon(Icons.label),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'El nombre es obligatorio.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Tipo
                        DropdownButtonFormField<ClientLocationType>(
                          decoration: const InputDecoration(
                            labelText: 'Tipo *',
                            prefixIcon: Icon(Icons.category),
                          ),
                          initialValue: _type,
                          items: ClientLocationType.values
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _type = value);
                          },
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Dirección
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Dirección',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Ciudad
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Ciudad',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          initialValue: _cityId,
                          items: _cities
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.displayName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _cityId = value),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // País
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'País',
                            prefixIcon: Icon(Icons.flag),
                          ),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Lat / Lng en fila
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Latitud',
                                  prefixIcon: Icon(Icons.explore),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final parsed = double.tryParse(value);
                                    if (parsed == null) {
                                      return 'Número inválido';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _longitudeController,
                                decoration: const InputDecoration(
                                  labelText: 'Longitud',
                                  prefixIcon: Icon(Icons.explore),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final parsed = double.tryParse(value);
                                    if (parsed == null) {
                                      return 'Número inválido';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Contacto nombre
                        TextFormField(
                          controller: _contactNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de Contacto',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Contacto teléfono
                        TextFormField(
                          controller: _contactPhoneController,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono de Contacto',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Estado (solo al editar)
                        if (isEditing) ...[
                          DropdownButtonFormField<ClientLocationStatus>(
                            decoration: const InputDecoration(
                              labelText: 'Estado',
                              prefixIcon: Icon(Icons.toggle_on),
                            ),
                            initialValue: _status,
                            items: ClientLocationStatus.values
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                          ),
                          const SizedBox(height: AppDefaults.margin),
                        ],

                        const SizedBox(height: AppDefaults.marginMedium),

                        // Botón guardar
                        BlocBuilder<ClientLocationBloc, ClientLocationState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status ==
                                    ClientLocationBlocStatus.creating ||
                                state.status ==
                                    ClientLocationBlocStatus.updating;

                            return FilledButton.icon(
                              onPressed: isLoading ? null : _submit,
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                isEditing
                                    ? 'Guardar Cambios'
                                    : 'Crear Ubicación',
                              ),
                            );
                          },
                        ),

                        // Error
                        BlocBuilder<ClientLocationBloc, ClientLocationState>(
                          builder: (context, state) {
                            if (state.status ==
                                    ClientLocationBlocStatus.failure &&
                                state.errorMessage.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: AppDefaults.margin,
                                ),
                                child: Text(
                                  state.errorMessage,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
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

    final lat = _latitudeController.text.isNotEmpty
        ? double.tryParse(_latitudeController.text)
        : null;
    final lng = _longitudeController.text.isNotEmpty
        ? double.tryParse(_longitudeController.text)
        : null;

    if (widget.isEditing) {
      context.read<ClientLocationBloc>().add(
        ClientLocationUpdateRequested(
          id: widget.location!.id,
          clientCompanyId: _clientCompanyId,
          name: _nameController.text.trim(),
          type: _type,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          cityId: _cityId,
          country: _countryController.text.trim(),
          latitude: lat,
          longitude: lng,
          contactName: _contactNameController.text.trim().isEmpty
              ? null
              : _contactNameController.text.trim(),
          contactPhone: _contactPhoneController.text.trim().isEmpty
              ? null
              : _contactPhoneController.text.trim(),
          status: _status,
        ),
      );
    } else {
      context.read<ClientLocationBloc>().add(
        ClientLocationCreateRequested(
          clientCompanyId: _clientCompanyId!,
          name: _nameController.text.trim(),
          type: _type,
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          cityId: _cityId,
          country: _countryController.text.trim(),
          latitude: lat,
          longitude: lng,
          contactName: _contactNameController.text.trim().isEmpty
              ? null
              : _contactNameController.text.trim(),
          contactPhone: _contactPhoneController.text.trim().isEmpty
              ? null
              : _contactPhoneController.text.trim(),
        ),
      );
    }
  }
}
