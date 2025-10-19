import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../dashboard/presentation/widgets/app_sidebar.dart';
import '../../data/datasources/medical_history_remote_data_source.dart';
import '../../data/repositories/medical_history_repository_impl.dart';
import '../../domain/usecases/get_medical_history_by_animal.dart';
import '../bloc/medical_history_bloc.dart';
import '../bloc/medical_history_event.dart';
import '../bloc/medical_history_state.dart';

class ClinicalHistoryScreen extends StatelessWidget {
  final int animalId;

  const ClinicalHistoryScreen({
    super.key,
    required this.animalId,
  });

  @override
  Widget build(BuildContext context) {
    print('DEBUG ClinicalHistoryScreen: animalId type: ${animalId.runtimeType}, value: $animalId');
    return BlocProvider(
      create: (context) {
        final bloc = MedicalHistoryBloc(
          getMedicalHistoryByAnimal: GetMedicalHistoryByAnimal(
            MedicalHistoryRepositoryImpl(
              remoteDataSource: MedicalHistoryRemoteDataSourceImpl(
                apiClient: ApiClient(),
              ),
            ),
          ),
        );
        
        // Cargar historial médico automáticamente
        print('DEBUG: Calling LoadMedicalHistory with animalId: $animalId');
        bloc.add(LoadMedicalHistory(animalId));
        
        return bloc;
      },
      child: ClinicalHistoryView(animalId: animalId),
    );
  }
}

class ClinicalHistoryView extends StatelessWidget {
  final int animalId;

  const ClinicalHistoryView({
    super.key,
    required this.animalId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            const AppSidebar(),
            Expanded(
              child: BlocBuilder<MedicalHistoryBloc, MedicalHistoryState>(
                builder: (context, state) {
                  if (state is MedicalHistoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is MedicalHistoryError) {
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
                            'Error al cargar el historial médico',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginSmall),
                          Text(
                            state.message,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimensions.marginLarge),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Volver'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is MedicalHistoryLoaded) {
                    final medicalHistory = state.medicalHistory;
                    
                    return Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppDimensions.marginMedium),
                                Text(
                                  'Historial Clínico',
                                  style: AppTextStyles.h2.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'ID Historial: ${medicalHistory.id}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // TabBar
                          Container(
                            color: Colors.white,
                            child: TabBar(
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              indicatorWeight: 3,
                              labelStyle: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.medical_services),
                                  text: 'Tratamientos',
                                ),
                                Tab(
                                  icon: Icon(Icons.vaccines),
                                  text: 'Vacunas',
                                ),
                                Tab(
                                  icon: Icon(Icons.health_and_safety),
                                  text: 'Diagnósticos',
                                ),
                              ],
                            ),
                          ),
                          
                          // TabBarView
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildTreatmentsTab(medicalHistory.id),
                                _buildVaccinesTab(medicalHistory.id),
                                _buildDiagnosesTab(medicalHistory.id),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentsTab(int medicalHistoryId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services,
            size: 64,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          Text(
            'Tratamientos',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'ID Historial Médico: $medicalHistoryId',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesTab(int medicalHistoryId) {
    return Center(
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
            'Vacunas',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'ID Historial Médico: $medicalHistoryId',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosesTab(int medicalHistoryId) {
    return Center(
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
            'Diagnósticos',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),
          Text(
            'ID Historial Médico: $medicalHistoryId',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
