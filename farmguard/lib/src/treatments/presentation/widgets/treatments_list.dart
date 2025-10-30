import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/treatment.dart';
import '../bloc/treatment_bloc.dart';
import '../bloc/treatment_event.dart';
import '../bloc/treatment_state.dart';
import 'add_treatment_dialog.dart';

class TreatmentsList extends StatelessWidget {
  final int medicalHistoryId;

  const TreatmentsList({
    super.key,
    required this.medicalHistoryId,
  });

  @override
  Widget build(BuildContext context) {
    // Cargar tratamientos cuando se construye el widget
    context.read<TreatmentBloc>().add(LoadTreatments(medicalHistoryId));

    return Scaffold(
      body: BlocBuilder<TreatmentBloc, TreatmentState>(
        builder: (context, state) {
          if (state is TreatmentLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TreatmentError) {
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
                    'Error al cargar tratamientos',
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

          if (state is TreatmentLoaded) {
            return _buildTreatmentContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: context.read<TreatmentBloc>(),
              child: AddTreatmentDialog(medicalHistoryId: medicalHistoryId),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTreatmentContent(BuildContext context, TreatmentLoaded state) {
    if (state.treatments.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
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
              0: FlexColumnWidth(2.0), // Título
              1: FlexColumnWidth(3.0), // Notas
              2: FlexColumnWidth(1.5), // Fecha de Inicio
              3: FlexColumnWidth(1.0), // Estado
              4: FlexColumnWidth(1.0), // Acciones
            },
            children: [
              TableRow(
                children: [
                  _buildHeaderCell('TÍTULO'),
                  _buildHeaderCell('NOTAS'),
                  _buildHeaderCell('FECHA DE INICIO'),
                  _buildHeaderCell('ESTADO'),
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
                0: FlexColumnWidth(2.0), // Título
                1: FlexColumnWidth(3.0), // Notas
                2: FlexColumnWidth(1.5), // Fecha de Inicio
                3: FlexColumnWidth(1.0), // Estado
                4: FlexColumnWidth(1.0), // Acciones
              },
              children: state.treatments
                  .map((treatment) => _buildDataRow(context, treatment))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            'No hay tratamientos registrados',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'Los tratamientos aparecerán aquí',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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

  TableRow _buildDataRow(BuildContext context, Treatment treatment) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      children: [
        _buildDataCell(treatment.title),
        _buildDataCell(treatment.notes),
        _buildDataCell(DateFormat('dd/MM/yyyy').format(treatment.startDate)),
        _buildStatusCell(treatment.status),
        _buildActionCell(context, treatment),
      ],
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

  Widget _buildStatusCell(bool status) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingLarge,
        ),
        child: Center(
          child: Text(
            status ? 'Activo' : 'Inactivo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: status ? Colors.green : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context, Treatment treatment) {
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
            onPressed: () => _showDeleteDialog(context, treatment),
            tooltip: 'Eliminar tratamiento',
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Treatment treatment) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Tratamiento'),
        content: Text('¿Está seguro que desea eliminar el tratamiento "${treatment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TreatmentBloc>().add(
                    DeleteTreatmentEvent(treatment.id),
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
