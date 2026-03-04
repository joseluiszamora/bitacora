import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/auth/authentication_bloc.dart';
import '../../core/blocs/finance/finance_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/data/models/finance_category.dart';
import '../../core/data/models/finance_group.dart';
import '../../core/data/models/finance_record.dart';

/// Formulario para crear o editar un movimiento financiero.
class FinanceRecordFormPage extends StatefulWidget {
  const FinanceRecordFormPage({super.key, this.record});

  final FinanceRecord? record;

  bool get isEditing => record != null;

  @override
  State<FinanceRecordFormPage> createState() => _FinanceRecordFormPageState();
}

class _FinanceRecordFormPageState extends State<FinanceRecordFormPage> {
  final _formKey = GlobalKey<FormState>();

  late FinanceRecordType _type;
  String? _groupId;
  String? _categoryId;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  DateTime? _recordDate;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _type = r?.type ?? FinanceRecordType.expense;
    _groupId = r?.groupId;
    _categoryId = r?.categoryId;
    _amountController = TextEditingController(
      text: r?.amount.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _recordDate = r?.recordDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
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
            widget.isEditing ? 'Editar Movimiento' : 'Nuevo Movimiento',
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDefaults.padding),
          child: Form(
            key: _formKey,
            child: BlocBuilder<FinanceBloc, FinanceState>(
              buildWhen: (prev, curr) =>
                  prev.activeGroups != curr.activeGroups ||
                  prev.activeCategories != curr.activeCategories ||
                  prev.status != curr.status,
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tipo: Ingreso / Egreso
                    _buildTypeSelector(),
                    const SizedBox(height: 16),

                    // Grupo
                    _buildGroupDropdown(state.activeGroups),
                    const SizedBox(height: 16),

                    // Categoría
                    _buildCategoryDropdown(state.activeCategories),
                    const SizedBox(height: 16),

                    // Monto
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Monto (Bs.)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el monto';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Ingrese un monto válido mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    _buildDatePicker(),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 24),

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

  Widget _buildTypeSelector() {
    return Row(
      children: FinanceRecordType.values.map((type) {
        final selected = _type == type;
        final color = type == FinanceRecordType.income
            ? AppColors.success
            : AppColors.error;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == FinanceRecordType.income ? 6 : 0,
              left: type == FinanceRecordType.expense ? 6 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _type = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? color.withAlpha(26) : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? color : AppColors.grey.withAlpha(77),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      type == FinanceRecordType.income
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: selected ? color : AppColors.grey,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type.label,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: selected ? color : AppColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupDropdown(List<FinanceGroup> groups) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Grupo *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDefaults.radiusSmall),
        ),
        prefixIcon: const Icon(Icons.folder_outlined),
        errorText: _submitted && _groupId == null
            ? 'Seleccione un grupo'
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _groupId,
          isExpanded: true,
          isDense: true,
          hint: const Text(
            'Seleccione un grupo',
            style: TextStyle(fontSize: 14),
          ),
          items: groups
              .map(
                (group) => DropdownMenuItem<String>(
                  value: group.id,
                  child: Text(group.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (id) => setState(() => _groupId = id),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<FinanceCategory> categories) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Categoría *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDefaults.radiusSmall),
        ),
        prefixIcon: const Icon(Icons.category_outlined),
        errorText: _submitted && _categoryId == null
            ? 'Seleccione una categoría'
            : null,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoryId,
          isExpanded: true,
          isDense: true,
          hint: const Text(
            'Seleccione una categoría',
            style: TextStyle(fontSize: 14),
          ),
          items: categories
              .map(
                (cat) => DropdownMenuItem<String>(
                  value: cat.id,
                  child: Text(cat.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (id) => setState(() => _categoryId = id),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    final formatted = _recordDate != null
        ? '${_recordDate!.day.toString().padLeft(2, '0')}/'
              '${_recordDate!.month.toString().padLeft(2, '0')}/'
              '${_recordDate!.year}'
        : 'Seleccione una fecha';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _recordDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _recordDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Fecha del movimiento *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDefaults.radiusSmall),
          ),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(formatted, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  void _onSubmit() {
    setState(() => _submitted = true);

    if (!_formKey.currentState!.validate()) return;

    if (_groupId == null || _categoryId == null || _recordDate == null) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final companyId = context.read<AuthenticationBloc>().state.user.company.id;

    if (widget.isEditing) {
      context.read<FinanceBloc>().add(
        FinanceRecordUpdateRequested(
          id: widget.record!.id,
          groupId: _groupId,
          categoryId: _categoryId,
          type: _type,
          amount: amount,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          recordDate: _recordDate,
        ),
      );
    } else {
      context.read<FinanceBloc>().add(
        FinanceRecordCreateRequested(
          companyId: companyId,
          groupId: _groupId!,
          categoryId: _categoryId!,
          type: _type,
          amount: amount,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          recordDate: _recordDate,
        ),
      );
    }
  }
}
