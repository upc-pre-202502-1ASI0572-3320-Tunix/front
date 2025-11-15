import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/treatment_bloc.dart';
import '../bloc/treatment_event.dart';
import '../bloc/treatment_state.dart';

class AddTreatmentDialog extends StatefulWidget {
  final int medicalHistoryId;

  const AddTreatmentDialog({
    super.key,
    required this.medicalHistoryId,
  });

  @override
  State<AddTreatmentDialog> createState() => _AddTreatmentDialogState();
}

class _AddTreatmentDialogState extends State<AddTreatmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  bool _status = true;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try {
        // Parseamos la fecha manualmente desde el campo de texto DD/MM/AAAA
        final dateParts = _dateController.text.trim().split('/');
        if (dateParts.length != 3) {
          throw FormatException('Formato de fecha inválido. Use DD/MM/AAAA');
        }

        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);
        final startDate = DateTime(year, month, day);
        
        context.read<TreatmentBloc>().add(
              CreateTreatmentEvent(
                medicalHistoryId: widget.medicalHistoryId,
                title: _titleController.text.trim(),
                notes: _notesController.text.trim(),
                startDate: startDate,
                status: _status,
              ),
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fecha inválida. Use formato DD/MM/AAAA'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TreatmentBloc, TreatmentState>(
      listener: (context, state) {
        if (state is TreatmentCreated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tratamiento agregado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is TreatmentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Center(
        child: SizedBox(
          width: 500,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 700,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: AppDimensions.marginMedium),
                          Text(
                            'Agregar Tratamiento',
                            style: AppTextStyles.h3.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginLarge),
                      
                      // Título
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese el título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),
                      
                      // Notas
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notas',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese las notas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),
                      
                      // Fecha de Inicio
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Fecha de Inicio (DD/MM/AAAA)',
                          hintText: '01/01/2024',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                        ),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingrese la fecha de inicio';
                          }
                          final dateParts = value.split('/');
                          if (dateParts.length != 3) {
                            return 'Formato de fecha inválido. Use DD/MM/AAAA';
                          }
                          try {
                            final day = int.parse(dateParts[0]);
                            final month = int.parse(dateParts[1]);
                            final year = int.parse(dateParts[2]);
                            
                            if (day < 1 || day > 31) {
                              return 'Día inválido';
                            }
                            if (month < 1 || month > 12) {
                              return 'Mes inválido';
                            }
                            if (year < 1900 || year > DateTime.now().year + 10) {
                              return 'Año inválido';
                            }
                          } catch (e) {
                            return 'Fecha inválida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.marginMedium),
                      
                      // Estado
                      Row(
                        children: [
                          Checkbox(
                            value: _status,
                            onChanged: (value) {
                              setState(() {
                                _status = value ?? true;
                              });
                            },
                            activeColor: AppColors.primary,
                          ),
                          const SizedBox(width: AppDimensions.marginSmall),
                          Text(
                            'Tratamiento activo',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.marginLarge),
                      
                      // Botones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.marginSmall),
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: BlocBuilder<TreatmentBloc, TreatmentState>(
                              builder: (context, state) {
                                return ElevatedButton(
                                  onPressed: state is TreatmentCreating ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: state is TreatmentCreating
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text('Guardar'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
