import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../dashboard/presentation/widgets/app_sidebar.dart';
import '../../../animals/data/datasources/animal_remote_data_source.dart';
import '../../../animals/data/repositories/animal_repository_impl.dart';
import '../../../animals/domain/usecases/get_animals_by_inventory.dart';
import '../../../animals/presentation/bloc/animal_bloc.dart';
import '../../../animals/presentation/bloc/animal_state.dart';
import '../../../animals/presentation/bloc/animal_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/medical_history_list_panel.dart';

class MedicalHistoryScreen extends StatelessWidget {
  const MedicalHistoryScreen({super.key});

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
        );
        
        // Cargar animales automáticamente
        animalBloc.add(LoadAnimals(inventoryId));
        
        return animalBloc;
      },
      child: const MedicalHistoryView(),
    );
  }
}

class MedicalHistoryView extends StatelessWidget {
  const MedicalHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: BlocConsumer<AnimalBloc, AnimalState>(
              listener: (context, state) {
                if (state is AnimalError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
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
                          'Error al cargar los animales',
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
                      ],
                    ),
                  );
                }

                if (state is AnimalLoaded) {
                  return const MedicalHistoryListPanel();
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
