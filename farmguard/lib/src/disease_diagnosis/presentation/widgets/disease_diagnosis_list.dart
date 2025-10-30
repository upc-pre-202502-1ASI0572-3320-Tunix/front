import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/disease_diagnosis.dart';
import '../bloc/disease_diagnosis_bloc.dart';
import '../bloc/disease_diagnosis_event.dart';
import '../bloc/disease_diagnosis_state.dart';
import 'add_disease_diagnosis_dialog.dart';

class DiseaseDiagnosisList extends StatelessWidget {
  final int medicalHistoryId;

  const DiseaseDiagnosisList({
    super.key,
    required this.medicalHistoryId,
  });

  @override
  Widget build(BuildContext context) {
    // Cargar diagnósticos cuando se construye el widget
    context.read<DiseaseDiagnosisBloc>().add(LoadDiseaseDiagnoses(medicalHistoryId));

    return BlocBuilder<DiseaseDiagnosisBloc, DiseaseDiagnosisState>(
      builder: (context, state) {
        if (state is DiseaseDiagnosisLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is DiseaseDiagnosisError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                Text(
                  'Error al cargar diagnósticos',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),
                Text(
                  state.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is DiseaseDiagnosisLoaded) {
          return _buildDiagnosisContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDiagnosisContent(BuildContext context, DiseaseDiagnosisLoaded state) {
    if (state.diagnoses.isEmpty) {
      return _buildEmptyState(context, state);
    }

    return Stack(
      children: [
        Column(
          children: [
            // Table Header
            Container(
              margin: const EdgeInsets.all(AppDimensions.marginLarge),
              decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5), // Severidad
              1: FlexColumnWidth(3.5), // Notas
              2: FlexColumnWidth(2.0), // Fecha de Diagnóstico
              3: FlexColumnWidth(1.0), // Acciones
            },
            children: [
              TableRow(
                children: [
                  _buildHeaderCell('SEVERIDAD'),
                  _buildHeaderCell('NOTAS'),
                  _buildHeaderCell('FECHA DE DIAGNÓSTICO'),
                  _buildHeaderCell('ACCIONES'),
                ],
              ),
            ],
          ),
        ),

        // Table Data
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.marginLarge,
            ),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1.5), // Severidad
                1: FlexColumnWidth(3.5), // Notas
                2: FlexColumnWidth(2.0), // Fecha de Diagnóstico
                3: FlexColumnWidth(1.0), // Acciones
              },
              children: state.diagnoses
                  .map((diagnosis) => _buildDataRow(context, diagnosis))
                  .toList(),
            ),
          ),
        ),
      ],
    ),
        // Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => BlocProvider.value(
                  value: context.read<DiseaseDiagnosisBloc>(),
                  child: AddDiseaseDiagnosisDialog(
                    medicalHistoryId: state.medicalHistoryId,
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, DiseaseDiagnosisLoaded state) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Icon(
            Icons.health_and_safety,
            size: 64,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            'No hay diagnósticos registrados',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Aún no se han registrado diagnósticos para este historial médico',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
        // Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => BlocProvider.value(
                  value: context.read<DiseaseDiagnosisBloc>(),
                  child: AddDiseaseDiagnosisDialog(
                    medicalHistoryId: state.medicalHistoryId,
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow(BuildContext context, DiseaseDiagnosis diagnosis) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      children: [
        _buildSeverityCell(diagnosis.severity),
        _buildDataCell(diagnosis.notes),
        _buildDataCell(DateFormat('dd/MM/yyyy HH:mm').format(diagnosis.diagnosedAt)),
        _buildActionCell(context, diagnosis),
      ],
    );
  }

  Widget _buildSeverityCell(Severity severity) {
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

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingLarge,
        ),
        child: Center(
          child: Text(
            severity.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: severityColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingLarge,
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context, DiseaseDiagnosis diagnosis) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingLarge,
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: 20,
            ),
            onPressed: () => _showDeleteDialog(context, diagnosis),
            tooltip: 'Eliminar diagnóstico',
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DiseaseDiagnosis diagnosis) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Diagnóstico'),
        content: const Text('¿Está seguro que desea eliminar este diagnóstico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<DiseaseDiagnosisBloc>().add(
                    DeleteDiseaseDiagnosisEvent(diagnosis.id),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
