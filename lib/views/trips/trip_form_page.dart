import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/auth/authentication_bloc.dart';
import '../../../core/blocs/company/company_bloc.dart';
import '../../../core/blocs/trip/trip_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/client_company.dart';
import '../../../core/data/models/client_location.dart';
import '../../../core/data/models/company.dart';
import '../../../core/data/models/trip.dart';
import '../../../core/data/models/user_role.dart';
import '../../../core/data/models/vehicle.dart';
import '../../../core/data/repositories/client_company_repository.dart';
import '../../../core/data/repositories/client_location_repository.dart';
import '../../../core/data/repositories/vehicle_repository.dart';

/// Formulario para crear o editar un viaje.
class TripFormPage extends StatefulWidget {
  const TripFormPage({super.key, this.trip});

  /// Si es null, se crea un nuevo viaje. Si tiene valor, se edita.
  final Trip? trip;

  bool get isEditing => trip != null;

  @override
  State<TripFormPage> createState() => _TripFormPageState();
}

class _TripFormPageState extends State<TripFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _priceController;

  late String _companyId;
  String? _clientCompanyId;
  String? _vehicleId;
  String? _originLocationId;
  String? _destinationLocationId;
  late TripStatus _status;
  DateTime? _departureTime;
  DateTime? _arrivalTime;

  bool _isSuperAdmin = false;
  List<Company> _companies = [];
  List<ClientCompany> _clientCompanies = [];
  List<Vehicle> _vehicles = [];
  List<ClientLocation> _clientLocations = [];

  @override
  void initState() {
    super.initState();
    final t = widget.trip;
    _priceController = TextEditingController(
      text: t?.price?.toStringAsFixed(2) ?? '',
    );

    _status = t?.status ?? TripStatus.pending;
    _departureTime = t?.departureTime;
    _arrivalTime = t?.arrivalTime;

    final authState = context.read<AuthenticationBloc>().state;
    _isSuperAdmin = authState.user.role == UserRole.superAdmin;
    _companyId = t?.companyId ?? authState.user.company.id;
    _clientCompanyId = t?.clientCompanyId;
    _vehicleId = t?.vehicleId;
    _originLocationId = t?.originLocationId;
    _destinationLocationId = t?.destinationLocationId;

    _loadRelatedData();
  }

  Future<void> _loadRelatedData() async {
    try {
      // Cargar empresas (solo super_admin)
      if (_isSuperAdmin) {
        final companyBloc = CompanyBloc()..add(const CompanyLoadRequested());
        await companyBloc.stream.firstWhere(
          (s) => s.status != CompanyStatus.loading,
        );
        if (mounted) {
          setState(() => _companies = companyBloc.state.companies);
        }
        await companyBloc.close();
      }

      // Cargar empresas cliente
      final clientCompanyRepo = ClientCompanyRepository();
      final clientCompanies = _isSuperAdmin
          ? await clientCompanyRepo.getAll()
          : await clientCompanyRepo.getAll();

      // Cargar vehículos
      final vehicleRepo = VehicleRepository();
      final vehicles = _companyId.isNotEmpty
          ? await vehicleRepo.getByCompany(_companyId)
          : await vehicleRepo.getAll();

      // Cargar ubicaciones de clientes
      final locationRepo = ClientLocationRepository();
      final locations = await locationRepo.getAll();

      if (mounted) {
        setState(() {
          _clientCompanies = clientCompanies;
          _vehicles = vehicles;
          _clientLocations = locations
              .where((l) => l.status == ClientLocationStatus.active)
              .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Error cargando datos relacionados: $e');
    }
  }

  /// Recarga vehículos y conductores al cambiar de empresa.
  Future<void> _onCompanyChanged(String newCompanyId) async {
    setState(() {
      _companyId = newCompanyId;
      _vehicleId = null;
      _vehicles = [];
    });

    try {
      final vehicleRepo = VehicleRepository();
      final vehicles = await vehicleRepo.getByCompany(newCompanyId);

      if (mounted) {
        setState(() {
          _vehicles = vehicles;
        });
      }
    } catch (e) {
      debugPrint('❌ Error recargando datos por empresa: $e');
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TripBloc, TripState>(
      listener: (context, state) {
        if (state.status == TripStateStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.status == TripStateStatus.failure &&
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
          title: Text(widget.isEditing ? 'Editar Viaje' : 'Nuevo Viaje'),
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
                      Icons.route,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Empresa (solo super_admin)
                  if (_isSuperAdmin) ...[
                    DropdownButtonFormField<String>(
                      initialValue: _companyId.isNotEmpty ? _companyId : null,
                      decoration: _inputDecoration(
                        label: 'Empresa Transportista *',
                        icon: Icons.business,
                      ),
                      items: _companies
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _onCompanyChanged(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Debes seleccionar una empresa.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDefaults.margin),
                  ],

                  // Empresa cliente
                  DropdownButtonFormField<String>(
                    initialValue: _clientCompanyId,
                    decoration: _inputDecoration(
                      label: 'Empresa Cliente *',
                      icon: Icons.storefront,
                    ),
                    items: _clientCompanies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _clientCompanyId = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes seleccionar una empresa cliente.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Vehículo
                  DropdownButtonFormField<String>(
                    initialValue: _vehicleId,
                    decoration: _inputDecoration(
                      label: 'Vehículo *',
                      icon: Icons.local_shipping,
                    ),
                    items: _vehicles
                        .where((v) => v.status == VehicleStatus.active)
                        .map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text('${v.plateNumber} — ${v.displayName}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _vehicleId = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Debes seleccionar un vehículo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Sección de ruta
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Ruta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Origen (ubicación del cliente)
                  DropdownButtonFormField<String>(
                    initialValue: _originLocationId,
                    decoration: _inputDecoration(
                      label: 'Origen *',
                      icon: Icons.trip_origin,
                    ),
                    items: _clientLocations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _originLocationId = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El origen es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Destino (ubicación del cliente)
                  DropdownButtonFormField<String>(
                    initialValue: _destinationLocationId,
                    decoration: _inputDecoration(
                      label: 'Destino *',
                      icon: Icons.flag,
                    ),
                    items: _clientLocations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _destinationLocationId = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El destino es obligatorio.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Sección de tiempos
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Horarios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Fecha/hora de salida
                  _DateTimePickerField(
                    label: 'Fecha y Hora de Salida',
                    icon: Icons.departure_board,
                    value: _departureTime,
                    onChanged: (dt) => setState(() => _departureTime = dt),
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Fecha/hora de llegada
                  _DateTimePickerField(
                    label: 'Fecha y Hora de Llegada',
                    icon: Icons.access_time_filled,
                    value: _arrivalTime,
                    onChanged: (dt) => setState(() => _arrivalTime = dt),
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Precio
                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Precio (Bs)',
                      icon: Icons.attach_money,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Precio inválido.';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Estado (solo en edición)
                  if (widget.isEditing) ...[
                    DropdownButtonFormField<TripStatus>(
                      initialValue: _status,
                      decoration: _inputDecoration(
                        label: 'Estado',
                        icon: Icons.toggle_on_outlined,
                      ),
                      items: TripStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
                    const SizedBox(height: AppDefaults.margin),
                  ],

                  const SizedBox(height: AppDefaults.marginMedium),

                  // Botón guardar
                  BlocBuilder<TripBloc, TripState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == TripStateStatus.creating ||
                          state.status == TripStateStatus.updating;

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
                              ? 'Actualizar Viaje'
                              : 'Crear Viaje',
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

    final bloc = context.read<TripBloc>();
    final priceText = _priceController.text.trim();
    final price = priceText.isNotEmpty ? double.tryParse(priceText) : null;

    // assigned_by_user_id = usuario actual que asigna el viaje
    final currentUserId = context.read<AuthenticationBloc>().state.user.id;

    if (widget.isEditing) {
      bloc.add(
        TripUpdateRequested(
          id: widget.trip!.id,
          companyId: _companyId,
          clientCompanyId: _clientCompanyId,
          vehicleId: _vehicleId,
          assignedByUserId: currentUserId,
          originLocationId: _originLocationId,
          destinationLocationId: _destinationLocationId,
          departureTime: _departureTime,
          arrivalTime: _arrivalTime,
          status: _status,
          price: price,
        ),
      );
    } else {
      bloc.add(
        TripCreateRequested(
          companyId: _companyId,
          clientCompanyId: _clientCompanyId!,
          vehicleId: _vehicleId!,
          assignedByUserId: currentUserId,
          originLocationId: _originLocationId!,
          destinationLocationId: _destinationLocationId!,
          departureTime: _departureTime,
          arrivalTime: _arrivalTime,
          price: price,
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

/// Widget para seleccionar fecha y hora.
class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayText = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/'
              '${value!.month.toString().padLeft(2, '0')}/'
              '${value!.year} '
              '${value!.hour.toString().padLeft(2, '0')}:'
              '${value!.minute.toString().padLeft(2, '0')}'
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(AppDefaults.radius),
      onTap: () async {
        // Primero seleccionar fecha
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          helpText: label,
        );
        if (pickedDate == null) return;

        // Luego seleccionar hora
        if (!context.mounted) return;
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: value != null
              ? TimeOfDay.fromDateTime(value!)
              : TimeOfDay.now(),
        );
        if (pickedTime == null) return;

        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onChanged(combined);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_month, color: AppColors.grey),
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
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: displayText.isNotEmpty ? AppColors.greyDark : AppColors.grey,
          ),
        ),
      ),
    );
  }
}
