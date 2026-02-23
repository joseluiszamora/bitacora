import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/vehicle_assignment/vehicle_assignment_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/user.dart';
import '../../core/data/models/user_role.dart';
import '../../core/data/models/vehicle.dart';
import '../../core/data/models/vehicle_assignment.dart';
import '../../core/data/repositories/user_repository.dart';
import '../../core/data/repositories/vehicle_repository.dart';

/// Formulario para crear o editar una asignación vehículo-conductor.
class VehicleAssignmentFormPage extends StatefulWidget {
  const VehicleAssignmentFormPage({super.key, this.assignment});

  /// Si es null, se crea una nueva asignación. Si tiene valor, se edita.
  final VehicleAssignment? assignment;

  bool get isEditing => assignment != null;

  @override
  State<VehicleAssignmentFormPage> createState() =>
      _VehicleAssignmentFormPageState();
}

class _VehicleAssignmentFormPageState extends State<VehicleAssignmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  String? _vehicleId;
  String? _driverId;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool _loadingVehicles = true;
  bool _loadingDrivers = true;
  List<Vehicle> _vehicles = [];
  List<User> _drivers = [];

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      final a = widget.assignment!;
      _vehicleId = a.vehicleId;
      _driverId = a.driverId;
      _startDate = a.startDate;
      _endDate = a.endDate;
    }

    _loadData();
  }

  Future<void> _loadData() async {
    final authState = context.read<AuthenticationBloc>().state;
    final currentUser = authState.user;
    final isSuperAdmin = currentUser.role == UserRole.superAdmin;
    final companyId = isSuperAdmin ? null : currentUser.company.id;

    // Cargar vehículos
    try {
      final vehicleRepo = GetIt.instance<VehicleRepository>();
      if (companyId != null && companyId.isNotEmpty) {
        _vehicles = await vehicleRepo.getByCompany(companyId);
      } else {
        _vehicles = await vehicleRepo.getAll();
      }
    } catch (e) {
      _vehicles = [];
    }
    if (mounted) setState(() => _loadingVehicles = false);

    // Cargar conductores (usuarios con rol driver) de la misma empresa
    try {
      final userRepo = GetIt.instance<UserRepository>();
      final allUsers = await userRepo.getAll(
        currentRole: currentUser.role,
        currentCompanyId: companyId,
        currentClientCompanyId: currentUser.clientCompany.id,
      );
      _drivers = allUsers
          .where((u) => u.role == UserRole.driver && u.isActive)
          .toList();
    } catch (e) {
      _drivers = [];
    }
    if (mounted) setState(() => _loadingDrivers = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return BlocListener<VehicleAssignmentBloc, VehicleAssignmentState>(
      listener: (context, state) {
        if (state.status == VehicleAssignmentStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar Asignación' : 'Nueva Asignación'),
        ),
        body: _loadingVehicles || _loadingDrivers
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDefaults.padding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Vehículo
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Vehículo *',
                            prefixIcon: Icon(Icons.local_shipping),
                          ),
                          initialValue: _vehicleId,
                          items: _vehicles
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(
                                    '${v.plateNumber} — ${v.displayName}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecciona un vehículo.';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              setState(() => _vehicleId = value),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Conductor
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Conductor *',
                            prefixIcon: Icon(Icons.person),
                          ),
                          initialValue: _driverId,
                          items: _drivers
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(
                                    d.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecciona un conductor.';
                            }
                            return null;
                          },
                          onChanged: (value) =>
                              setState(() => _driverId = value),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Fecha inicio
                        _DatePickerField(
                          label: 'Fecha de inicio *',
                          icon: Icons.calendar_today,
                          value: _startDate,
                          onChanged: (date) =>
                              setState(() => _startDate = date),
                        ),
                        const SizedBox(height: AppDefaults.margin),

                        // Fecha fin (opcional)
                        _DatePickerField(
                          label: 'Fecha de finalización (opcional)',
                          icon: Icons.event,
                          value: _endDate,
                          onChanged: (date) => setState(() => _endDate = date),
                          allowClear: true,
                          onClear: () => setState(() => _endDate = null),
                        ),
                        const SizedBox(height: AppDefaults.marginBig),

                        // Botón guardar
                        BlocBuilder<
                          VehicleAssignmentBloc,
                          VehicleAssignmentState
                        >(
                          builder: (context, state) {
                            final isLoading =
                                state.status ==
                                    VehicleAssignmentStatus.creating ||
                                state.status ==
                                    VehicleAssignmentStatus.updating;

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
                                    : 'Crear Asignación',
                              ),
                            );
                          },
                        ),

                        // Error
                        BlocBuilder<
                          VehicleAssignmentBloc,
                          VehicleAssignmentState
                        >(
                          builder: (context, state) {
                            if (state.status ==
                                    VehicleAssignmentStatus.failure &&
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

    final authState = context.read<AuthenticationBloc>().state;
    final currentUserId = authState.user.id;

    if (widget.isEditing) {
      context.read<VehicleAssignmentBloc>().add(
        VehicleAssignmentUpdateRequested(
          id: widget.assignment!.id,
          vehicleId: _vehicleId,
          driverId: _driverId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    } else {
      context.read<VehicleAssignmentBloc>().add(
        VehicleAssignmentCreateRequested(
          vehicleId: _vehicleId!,
          driverId: _driverId!,
          assignedByUserId: currentUserId,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    }
  }
}

/// Campo selector de fecha reutilizable.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
    this.allowClear = false,
    this.onClear,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool allowClear;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final displayText = value != null
        ? '${value!.day.toString().padLeft(2, '0')}/'
              '${value!.month.toString().padLeft(2, '0')}/'
              '${value!.year}'
        : 'Seleccionar fecha';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: allowClear && value != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: onClear,
                )
              : null,
        ),
        child: Text(
          displayText,
          style: TextStyle(color: value != null ? null : AppColors.grey),
        ),
      ),
    );
  }
}
