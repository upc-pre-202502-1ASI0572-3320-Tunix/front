import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../core/theme/theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../shared/widgets/custom_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/presentation/widgets/app_sidebar.dart';
import '../../data/datasources/animal_remote_data_source.dart';
import '../../data/datasources/iot_remote_data_source.dart';
import '../../data/repositories/animal_repository_impl.dart';
import '../../data/services/iot_sync_service.dart';
import '../../domain/usecases/get_animals_by_inventory.dart';
import '../bloc/animal_bloc.dart';
import '../bloc/animal_event.dart';
import '../bloc/animal_state.dart';
import '../widgets/animal_list_panel.dart';
import '../widgets/animal_detail_panel.dart';
import '../widgets/add_animal_dialog.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authState = context.read<AuthBloc>().state;
        final inventoryId = authState is Authenticated ? authState.user.inventoryId : 1;
        
        final animalBloc = AnimalBloc(
          getAnimalsByInventory: GetAnimalsByInventory(
            AnimalRepositoryImpl(
              remoteDataSource: AnimalRemoteDataSourceImpl(
                apiClient: ApiClient(),
              ),
            ),
          ),
          iotSyncService: IotSyncService(
            remoteDataSource: IotRemoteDataSourceImpl(
              httpClient: http.Client(),
            ),
          ),
        );
        
        // Cargar animales automáticamente
        animalBloc.add(LoadAnimals(inventoryId));
        
        return animalBloc;
      },
      child: const AnimalsView(),
    );
  }
}

class AnimalsView extends StatelessWidget {
  const AnimalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar
          const AppSidebar(currentRoute: 'animals'),
          
          // Contenido principal
          Expanded(
            child: BlocConsumer<AnimalBloc, AnimalState>(
              listener: (context, state) {
                if (state is AnimalError) {
                  CustomSnackbar.showError(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is AnimalLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is AnimalError) {
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
                          'Error al cargar animales',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppDimensions.marginSmall),
                        Text(
                          state.message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.marginLarge),
                        ElevatedButton.icon(
                          onPressed: () {
                            final authState = context.read<AuthBloc>().state;
                            final inventoryId = authState is Authenticated ? authState.user.inventoryId : 1;
                            context.read<AnimalBloc>().add(LoadAnimals(inventoryId));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AnimalLoaded) {
                  if (state.animals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets_outlined,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: AppDimensions.marginMedium),
                          Text(
                            'No hay animales registrados',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: AppDimensions.marginSmall),
                          Text(
                            'Agrega tu primer animal para comenzar',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.marginLarge),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AddAnimalDialog(
                                  animalBloc: context.read<AnimalBloc>(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar Animal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingLarge,
                                vertical: AppDimensions.paddingMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      // Panel izquierdo - Lista de animales (70%)
                      Expanded(
                        flex: 7,
                        child: AnimalListPanel(
                          animals: state.filteredAnimals,
                          selectedAnimalId: state.selectedAnimal?.id,
                        ),
                      ),
                      
                      // Divisor vertical
                      Container(
                        width: 1,
                        color: AppColors.divider,
                      ),
                      
                      // Panel derecho - Detalle del animal (30%)
                      Expanded(
                        flex: 3,
                        child: state.selectedAnimal != null
                            ? AnimalDetailPanel(animal: state.selectedAnimal!)
                            : Center(
                                child: Text(
                                  'Selecciona un animal',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
    );
  }
}
