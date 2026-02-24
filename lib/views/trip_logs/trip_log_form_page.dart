import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/trip_log/trip_log_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/trip_log.dart';
import '../../../core/data/models/user_role.dart';
import '../../../core/services/location_service.dart';

/// Formulario para crear o editar un log de viaje.
class TripLogFormPage extends StatefulWidget {
  const TripLogFormPage({
    super.key,
    required this.tripId,
    this.tripLog,
    required this.currentUserId,
    required this.currentUserRole,
  });

  final String tripId;
  final TripLog? tripLog;
  final String currentUserId;
  final UserRole currentUserRole;

  bool get isEditing => tripLog != null;

  @override
  State<TripLogFormPage> createState() => _TripLogFormPageState();
}

class _TripLogFormPageState extends State<TripLogFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late TripLogEventType _eventType;
  bool _isLoadingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final log = widget.tripLog;
    _descriptionController = TextEditingController(
      text: log?.description ?? '',
    );
    _latitudeController = TextEditingController(
      text: log?.latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: log?.longitude?.toString() ?? '',
    );
    _eventType = log?.eventType ?? TripLogEventType.assigned;

    // Obtener ubicación automáticamente al crear un nuevo evento.
    if (!widget.isEditing) {
      _fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Evento' : 'Nuevo Evento'),
      ),
      body: BlocListener<TripLogBloc, TripLogState>(
        listener: (context, state) {
          if (state.status == TripLogStateStatus.success) {
            Navigator.of(context).pop();
          }
          if (state.status == TripLogStateStatus.failure &&
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDefaults.padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tipo de evento
                  DropdownButtonFormField<TripLogEventType>(
                    initialValue: _eventType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Evento *',
                      prefixIcon: Icon(Icons.event_note),
                    ),
                    items: TripLogEventType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text('${type.icon} ${type.label}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _eventType = value);
                      }
                    },
                    validator: (value) {
                      if (value == null) return 'Selecciona un tipo de evento';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción / Comentario',
                      prefixIcon: Icon(Icons.comment_outlined),
                      hintText: 'Describe el evento...',
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),

                  // Ubicación GPS
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Ubicación GPS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        TextButton.icon(
                          onPressed: _fetchCurrentLocation,
                          icon: const Icon(Icons.gps_fixed, size: 18),
                          label: Text(
                            _latitudeController.text.isNotEmpty
                                ? 'Actualizar'
                                : 'Obtener',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryAccent,
                          ),
                        ),
                    ],
                  ),
                  if (_locationError != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _locationError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Latitud',
                            prefixIcon: Icon(Icons.my_location),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final lat = double.tryParse(value);
                              if (lat == null || lat < -90 || lat > 90) {
                                return 'Latitud inválida';
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
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final lng = double.tryParse(value);
                              if (lng == null || lng < -180 || lng > 180) {
                                return 'Longitud inválida';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón guardar
                  BlocBuilder<TripLogBloc, TripLogState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == TripLogStateStatus.creating ||
                          state.status == TripLogStateStatus.updating;
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
                        label: Text(widget.isEditing ? 'Actualizar' : 'Crear'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
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

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();
      if (!mounted) return;

      if (position != null) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _isLoadingLocation = false;
        });
      } else {
        // Obtener un mensaje descriptivo del motivo.
        final message = await LocationService.getPermissionMessage();
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
          _locationError = message.isNotEmpty
              ? message
              : 'No se pudo obtener la ubicación.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
        _locationError = 'Error obteniendo ubicación: $e';
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final lat = _latitudeController.text.isNotEmpty
        ? double.tryParse(_latitudeController.text)
        : null;
    final lng = _longitudeController.text.isNotEmpty
        ? double.tryParse(_longitudeController.text)
        : null;
    final desc = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : null;

    // Determinar si registrar como user_id o driver_id.
    final isDriver = widget.currentUserRole == UserRole.driver;

    if (widget.isEditing) {
      context.read<TripLogBloc>().add(
        TripLogUpdateRequested(
          id: widget.tripLog!.id,
          eventType: _eventType,
          description: desc,
          latitude: lat,
          longitude: lng,
        ),
      );
    } else {
      context.read<TripLogBloc>().add(
        TripLogCreateRequested(
          tripId: widget.tripId,
          userId: isDriver ? null : widget.currentUserId,
          driverId: isDriver ? widget.currentUserId : null,
          eventType: _eventType,
          description: desc,
          latitude: lat,
          longitude: lng,
        ),
      );
    }
  }
}
