import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/disease_diagnosis.dart';
import '../bloc/disease_diagnosis_bloc.dart';
import '../bloc/disease_diagnosis_event.dart';
import '../bloc/disease_diagnosis_state.dart';

class AddDiseaseDiagnosisDialog extends StatefulWidget {
  final int medicalHistoryId;

  const AddDiseaseDiagnosisDialog({
    super.key,
    required this.medicalHistoryId,
  });

  @override
  State<AddDiseaseDiagnosisDialog> createState() => _AddDiseaseDiagnosisDialogState();
}

class _AddDiseaseDiagnosisDialogState extends State<AddDiseaseDiagnosisDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateTime.now().toUtc().toIso8601String(),
  );
  Severity _selectedSeverity = Severity.leve;

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      try {
        // Parsear la fecha ISO 8601 directamente
        final diagnosedAt = DateTime.parse(_dateController.text.trim());
        
        context.read<DiseaseDiagnosisBloc>().add(
              CreateDiseaseDiagnosisEvent(
                medicalHistoryId: widget.medicalHistoryId,
                severity: _selectedSeverity.value,
                notes: _notesController.text.trim(),
                diagnosedAt: diagnosedAt,
              ),
            );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Formato de fecha inválido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiseaseDiagnosisBloc, DiseaseDiagnosisState>(
      listener: (context, state) {
        if (state is DiseaseDiagnosisCreated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diagnóstico agregado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is DiseaseDiagnosisError) {
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
                maxHeight: 600,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: AppDimensions.marginMedium),
                      Text(
                        'Agregar Diagnóstico',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.marginLarge),
                  
                  // Severidad Dropdown
                  DropdownButtonFormField<Severity>(
                    initialValue: _selectedSeverity,
                    decoration: InputDecoration(
                      labelText: 'Severidad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    items: Severity.values.map((severity) {
                      Color severityColor;
                      switch (severity) {
                        case Severity.leve:
                          severityColor = Colors.green;
                          break;
                        case Severity.moderado:
                          severityColor = Colors.orange;
                          break;
                        case Severity.grave:
                          severityColor = AppColors.error;
                          break;
                      }
                      return DropdownMenuItem<Severity>(
                        value: severity,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: severityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(severity.label),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Severity? value) {
                      if (value != null) {
                        setState(() {
                          _selectedSeverity = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Por favor seleccione la severidad';
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
                  
                  // Fecha de Diagnóstico
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Diagnóstico (ISO 8601)',
                      hintText: '2025-10-30T18:14:33.857Z',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        borderSide: BorderSide(color: AppColors.primary, width: 2),
                      ),
                      suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingrese la fecha';
                      }
                      try {
                        DateTime.parse(value.trim());
                        return null;
                      } catch (e) {
                        return 'Formato inválido. Use ISO 8601';
                      }
                    },
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
                        child: BlocBuilder<DiseaseDiagnosisBloc, DiseaseDiagnosisState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is DiseaseDiagnosisCreating ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: state is DiseaseDiagnosisCreating
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
