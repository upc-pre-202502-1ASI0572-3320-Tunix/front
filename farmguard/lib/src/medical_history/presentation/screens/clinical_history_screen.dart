import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../dashboard/presentation/widgets/app_sidebar.dart';
import '../../../vaccines/data/datasources/vaccine_remote_data_source.dart';
import '../../../vaccines/data/repositories/vaccine_repository_impl.dart';
import '../../../vaccines/domain/usecases/get_vaccines_by_medical_history.dart';
import '../../../vaccines/domain/usecases/create_vaccine.dart';
import '../../../vaccines/domain/usecases/delete_vaccine.dart';
import '../../../vaccines/presentation/bloc/vaccine_bloc.dart';
import '../../../vaccines/presentation/widgets/vaccines_list.dart';
import '../../../disease_diagnosis/data/datasources/disease_diagnosis_remote_data_source.dart';
import '../../../disease_diagnosis/data/repositories/disease_diagnosis_repository_impl.dart';
import '../../../disease_diagnosis/domain/usecases/get_disease_diagnosis_by_medical_history.dart';
import '../../../disease_diagnosis/domain/usecases/create_disease_diagnosis.dart';
import '../../../disease_diagnosis/domain/usecases/delete_disease_diagnosis.dart';
import '../../../disease_diagnosis/presentation/bloc/disease_diagnosis_bloc.dart';
import '../../../disease_diagnosis/presentation/widgets/disease_diagnosis_list.dart';
import '../../../treatments/data/datasources/treatment_remote_data_source.dart';
import '../../../treatments/data/repositories/treatment_repository_impl.dart';
import '../../../treatments/domain/usecases/get_treatments_by_medical_history.dart';
import '../../../treatments/domain/usecases/create_treatment.dart';
import '../../../treatments/domain/usecases/delete_treatment.dart';
import '../../../treatments/presentation/bloc/treatment_bloc.dart';
import '../../../treatments/presentation/widgets/treatments_list.dart';
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
                    
                    return Column(
                      children: [
                        // Header - Ocupa todo el ancho
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
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
                                    color: AppColors.primary.withValues(alpha: 0.1),
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
                        
                        // Contenido con ancho máximo y banners laterales
                        Expanded(
                          child: Row(
                            children: [
                              // Banner izquierdo (FÁCIL DE BORRAR - INICIO)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  color: AppColors.background,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.network(
                                        'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNXlmcTM0Ymp2bW8wYjZjM2YxaWZiZzRvNm5wZDNjbnU5dzRlMzk3diZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/90LjOXKULOl0pwh1qd/giphy.gif',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Banner izquierdo (FÁCIL DE BORRAR - FIN)
                              
                              // Contenido central
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1200),
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                  text: 'Tratamientos',
                                ),
                                Tab(
                                  text: 'Vacunas',
                                ),
                                Tab(
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
                    ),
                  ),
                  
                  // Banner derecho (FÁCIL DE BORRAR - INICIO)
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: AppColors.background,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.network(
                            'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNXlmcTM0Ymp2bW8wYjZjM2YxaWZiZzRvNm5wZDNjbnU5dzRlMzk3diZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/90LjOXKULOl0pwh1qd/giphy.gif',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Banner derecho (FÁCIL DE BORRAR - FIN)
                ],
              ),
            ),
          ],
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
    final repository = TreatmentRepositoryImpl(
      remoteDataSource: TreatmentRemoteDataSourceImpl(
        apiClient: ApiClient(),
      ),
    );

    return BlocProvider(
      create: (context) => TreatmentBloc(
        getTreatmentsByMedicalHistory: GetTreatmentsByMedicalHistory(repository),
        createTreatment: CreateTreatment(repository),
        deleteTreatment: DeleteTreatment(repository),
      ),
      child: TreatmentsList(medicalHistoryId: medicalHistoryId),
    );
  }

  Widget _buildVaccinesTab(int medicalHistoryId) {
    final repository = VaccineRepositoryImpl(
      remoteDataSource: VaccineRemoteDataSourceImpl(
        apiClient: ApiClient(),
      ),
    );

    return BlocProvider(
      create: (context) => VaccineBloc(
        getVaccinesByMedicalHistory: GetVaccinesByMedicalHistory(repository),
        createVaccine: CreateVaccine(repository),
        deleteVaccine: DeleteVaccine(repository),
      ),
      child: VaccinesList(medicalHistoryId: medicalHistoryId),
    );
  }

  Widget _buildDiagnosesTab(int medicalHistoryId) {
    final repository = DiseaseDiagnosisRepositoryImpl(
      remoteDataSource: DiseaseDiagnosisRemoteDataSourceImpl(
        apiClient: ApiClient(),
      ),
    );

    return BlocProvider(
      create: (context) => DiseaseDiagnosisBloc(
        getDiseaseDiagnosisByMedicalHistory: GetDiseaseDiagnosisByMedicalHistory(repository),
        createDiseaseDiagnosis: CreateDiseaseDiagnosis(repository),
        deleteDiseaseDiagnosis: DeleteDiseaseDiagnosis(repository),
      ),
      child: DiseaseDiagnosisList(medicalHistoryId: medicalHistoryId),
    );
  }
}
