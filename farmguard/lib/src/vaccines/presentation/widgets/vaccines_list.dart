import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/vaccine.dart';
import '../bloc/vaccine_bloc.dart';
import '../bloc/vaccine_event.dart';
import '../bloc/vaccine_state.dart';
import 'add_vaccine_dialog.dart';

class VaccinesList extends StatelessWidget {
  final int medicalHistoryId;

  const VaccinesList({
    super.key,
    required this.medicalHistoryId,
  });

  @override
  Widget build(BuildContext context) {
    // Cargar vacunas cuando se construye el widget
    context.read<VaccineBloc>().add(LoadVaccines(medicalHistoryId));

    return BlocBuilder<VaccineBloc, VaccineState>(
      builder: (context, state) {
        if (state is VaccineLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is VaccineError) {
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
                  'Error al cargar vacunas',
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

        if (state is VaccineLoaded) {
          return _buildVaccinesContent(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildVaccinesContent(BuildContext context, VaccineLoaded state) {
    if (state.vaccines.isEmpty) {
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
                  0: FlexColumnWidth(2.0), // Nombre
                  1: FlexColumnWidth(2.5), // Fabricante
                  2: FlexColumnWidth(3.0), // Esquema
                  3: FlexColumnWidth(1.0), // Acciones
                },
                children: [
                  TableRow(
                    children: [
                      _buildHeaderCell('NOMBRE'),
                      _buildHeaderCell('FABRICANTE'),
                      _buildHeaderCell('ESQUEMA'),
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
                    0: FlexColumnWidth(2.0), // Nombre
                    1: FlexColumnWidth(2.5), // Fabricante
                    2: FlexColumnWidth(3.0), // Esquema
                    3: FlexColumnWidth(1.0), // Acciones
                  },
                  children: state.vaccines
                      .map((vaccine) => _buildDataRow(context, vaccine, state.medicalHistoryId))
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
                  value: context.read<VaccineBloc>(),
                  child: AddVaccineDialog(
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

  Widget _buildEmptyState(BuildContext context, VaccineLoaded state) {
    return Stack(
      children: [
        // Empty state
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.vaccines,
                size: 64,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: AppDimensions.marginMedium),
              Text(
                'No hay vacunas registradas',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.marginSmall),
              Text(
                'Aún no se han registrado vacunas para este historial médico',
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
                  value: context.read<VaccineBloc>(),
                  child: AddVaccineDialog(
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

  TableRow _buildDataRow(BuildContext context, Vaccine vaccine, int medicalHistoryId) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      children: [
        _buildDataCell(vaccine.name),
        _buildDataCell(vaccine.manufacturer),
        _buildDataCell(vaccine.schema),
        _buildActionCell(context, vaccine, medicalHistoryId),
      ],
    );
  }

  Widget _buildActionCell(BuildContext context, Vaccine vaccine, int medicalHistoryId) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingLarge,
        ),
        child: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              icon: const Icon(Icons.delete),
              color: AppColors.error,
              iconSize: 20,
              onPressed: () {
                _showDeleteConfirmation(context, vaccine, medicalHistoryId);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Vaccine vaccine, int medicalHistoryId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar la vacuna "${vaccine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<VaccineBloc>().add(
                DeleteVaccineEvent(
                  vaccineId: vaccine.id,
                  medicalHistoryId: medicalHistoryId,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
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
}
