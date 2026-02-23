import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/blocs/auth/authentication_bloc.dart';
import '../../../core/blocs/company/company_bloc.dart';
import '../../../core/blocs/vehicle/vehicle_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_defaults.dart';
import '../../../core/data/models/company.dart';
import '../../../core/data/models/user_role.dart';
import '../../../core/data/models/vehicle.dart';

/// Formulario para crear o editar un vehículo.
class VehicleFormPage extends StatefulWidget {
  const VehicleFormPage({super.key, this.vehicle});

  /// Si es null, se crea un nuevo vehículo. Si tiene valor, se edita.
  final Vehicle? vehicle;

  bool get isEditing => vehicle != null;

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _chasisController;
  late final TextEditingController _motorController;
  late final TextEditingController _ruatController;

  late String _companyId;
  late VehicleStatus _status;
  DateTime? _soatExpDate;
  DateTime? _inspectionExpDate;
  DateTime? _insuranceExpDate;

  bool _isSuperAdmin = false;
  List<Company> _companies = [];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _plateController = TextEditingController(text: v?.plateNumber ?? '');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v?.year?.toString() ?? '');
    _colorController = TextEditingController(text: v?.color ?? '');
    _chasisController = TextEditingController(text: v?.chasisCode ?? '');
    _motorController = TextEditingController(text: v?.motorCode ?? '');
    _ruatController = TextEditingController(text: v?.ruatNumber ?? '');

    _status = v?.status ?? VehicleStatus.active;
    _soatExpDate = v?.soatExpirationDate;
    _inspectionExpDate = v?.inspectionExpirationDate;
    _insuranceExpDate = v?.insuranceExpirationDate;

    final authState = context.read<AuthenticationBloc>().state;
    _isSuperAdmin = authState.user.role == UserRole.superAdmin;
    _companyId = v?.companyId ?? authState.user.company.id;

    if (_isSuperAdmin) {
      // Cargar empresas para el dropdown
      _loadCompanies();
    }
  }

  Future<void> _loadCompanies() async {
    try {
      // Usamos el bloc de compañías si está disponible, sino creamos uno
      final companyBloc = CompanyBloc()..add(const CompanyLoadRequested());
      await companyBloc.stream.firstWhere(
        (s) => s.status != CompanyStatus.loading,
      );
      if (mounted) {
        setState(() {
          _companies = companyBloc.state.companies;
        });
      }
      await companyBloc.close();
    } catch (e) {
      debugPrint('❌ Error cargando compañías: $e');
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _chasisController.dispose();
    _motorController.dispose();
    _ruatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state.status == VehicleStateStatus.success) {
          Navigator.of(context).pop();
        }
        if (state.status == VehicleStateStatus.failure &&
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
          title: Text(widget.isEditing ? 'Editar Vehículo' : 'Nuevo Vehículo'),
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
                      Icons.local_shipping,
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
                        label: 'Empresa *',
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
                        if (value != null) setState(() => _companyId = value);
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

                  // Placa *
                  TextFormField(
                    controller: _plateController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Placa *',
                      icon: Icons.confirmation_number_outlined,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La placa es obligatoria.';
                      }
                      if (value.trim().length < 3) {
                        return 'La placa debe tener al menos 3 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Marca y Modelo en fila
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _brandController,
                          style: const TextStyle(color: AppColors.greyDark),
                          decoration: _inputDecoration(
                            label: 'Marca',
                            icon: Icons.branding_watermark_outlined,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _modelController,
                          style: const TextStyle(color: AppColors.greyDark),
                          decoration: _inputDecoration(
                            label: 'Modelo',
                            icon: Icons.directions_car_outlined,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Año y Color en fila
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _yearController,
                          style: const TextStyle(color: AppColors.greyDark),
                          decoration: _inputDecoration(
                            label: 'Año',
                            icon: Icons.calendar_today_outlined,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              final year = int.tryParse(value.trim());
                              if (year == null ||
                                  year < 1900 ||
                                  year > DateTime.now().year + 1) {
                                return 'Año inválido.';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          style: const TextStyle(color: AppColors.greyDark),
                          decoration: _inputDecoration(
                            label: 'Color',
                            icon: Icons.palette_outlined,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Código chasis
                  TextFormField(
                    controller: _chasisController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Código de Chasis',
                      icon: Icons.qr_code_outlined,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Código motor
                  TextFormField(
                    controller: _motorController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Código de Motor',
                      icon: Icons.settings_outlined,
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Número RUAT
                  TextFormField(
                    controller: _ruatController,
                    style: const TextStyle(color: AppColors.greyDark),
                    decoration: _inputDecoration(
                      label: 'Número RUAT',
                      icon: Icons.numbers,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // Sección de fechas de vencimiento
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Fechas de Vencimiento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // SOAT
                  _DatePickerField(
                    label: 'Vencimiento SOAT',
                    icon: Icons.health_and_safety_outlined,
                    value: _soatExpDate,
                    onChanged: (date) => setState(() => _soatExpDate = date),
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Inspección Técnica
                  _DatePickerField(
                    label: 'Vencimiento Inspección Técnica',
                    icon: Icons.assignment_outlined,
                    value: _inspectionExpDate,
                    onChanged: (date) =>
                        setState(() => _inspectionExpDate = date),
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Seguro
                  _DatePickerField(
                    label: 'Vencimiento Seguro',
                    icon: Icons.shield_outlined,
                    value: _insuranceExpDate,
                    onChanged: (date) =>
                        setState(() => _insuranceExpDate = date),
                  ),
                  const SizedBox(height: AppDefaults.margin),

                  // Estado (solo en edición)
                  if (widget.isEditing) ...[
                    DropdownButtonFormField<VehicleStatus>(
                      initialValue: _status,
                      decoration: _inputDecoration(
                        label: 'Estado',
                        icon: Icons.toggle_on_outlined,
                      ),
                      items: VehicleStatus.values
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
                  BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == VehicleStateStatus.creating ||
                          state.status == VehicleStateStatus.updating;

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
                              ? 'Actualizar Vehículo'
                              : 'Crear Vehículo',
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

    final bloc = context.read<VehicleBloc>();
    final plate = _plateController.text.trim().toUpperCase();
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final yearText = _yearController.text.trim();
    final color = _colorController.text.trim();
    final chasis = _chasisController.text.trim();
    final motor = _motorController.text.trim();
    final ruat = _ruatController.text.trim();
    final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;

    if (widget.isEditing) {
      bloc.add(
        VehicleUpdateRequested(
          id: widget.vehicle!.id,
          companyId: _companyId,
          plateNumber: plate,
          brand: brand.isNotEmpty ? brand : null,
          model: model.isNotEmpty ? model : null,
          year: year,
          color: color.isNotEmpty ? color : null,
          chasisCode: chasis.isNotEmpty ? chasis : null,
          motorCode: motor.isNotEmpty ? motor : null,
          ruatNumber: ruat.isNotEmpty ? ruat : null,
          soatExpirationDate: _soatExpDate,
          inspectionExpirationDate: _inspectionExpDate,
          insuranceExpirationDate: _insuranceExpDate,
          status: _status,
        ),
      );
    } else {
      bloc.add(
        VehicleCreateRequested(
          companyId: _companyId,
          plateNumber: plate,
          brand: brand.isNotEmpty ? brand : null,
          model: model.isNotEmpty ? model : null,
          year: year,
          color: color.isNotEmpty ? color : null,
          chasisCode: chasis.isNotEmpty ? chasis : null,
          motorCode: motor.isNotEmpty ? motor : null,
          ruatNumber: ruat.isNotEmpty ? ruat : null,
          soatExpirationDate: _soatExpDate,
          inspectionExpirationDate: _inspectionExpDate,
          insuranceExpirationDate: _insuranceExpDate,
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

/// Widget para seleccionar una fecha.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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
              '${value!.year}'
        : '';

    return InkWell(
      borderRadius: BorderRadius.circular(AppDefaults.radius),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          helpText: label,
        );
        if (picked != null) {
          onChanged(picked);
        }
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
