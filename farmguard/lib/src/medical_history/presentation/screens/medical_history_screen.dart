import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/network/api_client.dart';
import '../../../dashboard/presentation/widgets/app_sidebar.dart';
import '../../../animals/data/datasources/animal_remote_data_source.dart';
import '../../../animals/data/datasources/telemetry_signalr_service.dart';
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
          telemetryService: TelemetrySignalRService(),
        );
        
        // Cargar animales automáticamente
        animalBloc.add(LoadAnimals(inventoryId));
        
        // Conectar a telemetría con todos los collares (listener en la vista)
        
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
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: isMobile
          ? Drawer(
              child: Container(
                color: AppColors.background,
                child: const AppSidebar(currentRoute: 'medical_history'),
              ),
            )
          : null,
      appBar: isMobile
          ? AppBar(
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: const Text('Historial Médico'),
            )
          : null,
      body: Row(
        children: [
          // Sidebar - solo en desktop
          if (!isMobile) const AppSidebar(currentRoute: 'medical_history'),
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
                // Conectar a telemetría cuando los animales se cargen
                if (state is AnimalLoaded && state.animals.isNotEmpty) {
                  // Extraer todos los deviceIds (collares)
                  final deviceIds = state.animals
                      .map((a) => a.deviceId)
                      .where((id) => id.isNotEmpty)
                      .toList();
                  
                  if (deviceIds.isNotEmpty) {
                    final filterString = deviceIds.join(',');
                    debugPrint('[MedicalHistoryScreen] 🔗 Conectando con dispositivos: $filterString');
                    context.read<AnimalBloc>().add(ConnectTelemetry(filter: filterString));
                  }
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium,
                          ),
                          child: Text(
                            state.message,
                            style: AppTextStyles.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
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
