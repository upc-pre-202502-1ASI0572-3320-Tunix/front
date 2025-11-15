import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/animal.dart';
import '../../domain/usecases/get_animals_by_inventory.dart';
import '../../data/services/iot_sync_service.dart';
import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final GetAnimalsByInventory getAnimalsByInventory;
  final IotSyncService iotSyncService;
  StreamSubscription? _iotDataSubscription;

  AnimalBloc({
    required this.getAnimalsByInventory,
    required this.iotSyncService,
  }) : super(AnimalInitial()) {
    on<LoadAnimals>(_onLoadAnimals);
    on<SelectAnimal>(_onSelectAnimal);
    on<FilterAnimals>(_onFilterAnimals);
    on<StartIotSync>(_onStartIotSync);
    on<StopIotSync>(_onStopIotSync);
    on<UpdateAnimalIotData>(_onUpdateAnimalIotData);
  }

  Future<void> _onLoadAnimals(
    LoadAnimals event,
    Emitter<AnimalState> emit,
  ) async {
    emit(AnimalLoading());

    final result = await getAnimalsByInventory(event.inventoryId);

    result.fold(
      (failure) => emit(AnimalError(failure.message)),
      (animals) {
        if (animals.isEmpty) {
          emit(const AnimalLoaded(animals: []));
        } else {
          // Seleccionar el primer animal por defecto
          emit(AnimalLoaded(
            animals: animals,
            selectedAnimal: animals.first,
          ));
        }
      },
    );
  }

  void _onSelectAnimal(
    SelectAnimal event,
    Emitter<AnimalState> emit,
  ) {
    if (state is AnimalLoaded) {
      final currentState = state as AnimalLoaded;
      final selectedAnimal = currentState.filteredAnimals.firstWhere(
        (animal) => animal.id == event.animalId,
      );
      emit(currentState.copyWith(selectedAnimal: selectedAnimal));
    }
  }

  void _onFilterAnimals(
    FilterAnimals event,
    Emitter<AnimalState> emit,
  ) {
    if (state is AnimalLoaded) {
      final currentState = state as AnimalLoaded;
      
      List<Animal> filtered = currentState.animals;
      
      // Aplicar filtro de búsqueda (mínimo 3 caracteres)
      if (event.searchQuery != null && event.searchQuery!.length >= 3) {
        filtered = filtered.where((animal) {
          return animal.name.toLowerCase().contains(event.searchQuery!.toLowerCase());
        }).toList();
      }
      
      // Aplicar filtro de especie
      if (event.specieFilter != null && event.specieFilter!.isNotEmpty) {
        filtered = filtered.where((animal) {
          return animal.specie == event.specieFilter;
        }).toList();
      }
      
      emit(currentState.copyWith(
        filteredAnimals: filtered,
        searchQuery: event.searchQuery,
        specieFilter: event.specieFilter,
        selectedAnimal: filtered.isNotEmpty ? filtered.first : null,
      ));
    }
  }

  Future<void> _onStartIotSync(
    StartIotSync event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      // Detener sincronización previa si existe
      await _iotDataSubscription?.cancel();
      iotSyncService.stopSync();

      // Iniciar nueva sincronización
      await iotSyncService.startSync(event.iotUrl);

      // Escuchar cambios en los datos IoT
      _iotDataSubscription = iotSyncService.dataStream.listen((iotData) {
        // Emitir evento para actualizar el animal con los nuevos datos
        add(UpdateAnimalIotData(
          animalId: event.animalId,
          heartRate: iotData.heartRate,
          temperature: iotData.temperature, // Ya es double
          location: iotData.location,
        ));
      });
    } catch (e) {
      // Error de sincronización - ignorar silenciosamente
    }
  }

  void _onStopIotSync(
    StopIotSync event,
    Emitter<AnimalState> emit,
  ) {
    _iotDataSubscription?.cancel();
    _iotDataSubscription = null;
    iotSyncService.stopSync();
  }

  void _onUpdateAnimalIotData(
    UpdateAnimalIotData event,
    Emitter<AnimalState> emit,
  ) {
    if (state is AnimalLoaded) {
      final currentState = state as AnimalLoaded;

      // Actualizar el animal en la lista principal
      final updatedAnimals = currentState.animals.map((animal) {
        if (animal.id == event.animalId) {
          return animal.copyWith(
            hearRate: event.heartRate,
            temperature: event.temperature,
            location: event.location,
          );
        }
        return animal;
      }).toList();

      // Actualizar el animal en la lista filtrada
      final updatedFilteredAnimals = currentState.filteredAnimals.map((animal) {
        if (animal.id == event.animalId) {
          return animal.copyWith(
            hearRate: event.heartRate,
            temperature: event.temperature,
            location: event.location,
          );
        }
        return animal;
      }).toList();

      // Actualizar el animal seleccionado si corresponde
      Animal? updatedSelectedAnimal = currentState.selectedAnimal;
      if (updatedSelectedAnimal != null && updatedSelectedAnimal.id == event.animalId) {
        updatedSelectedAnimal = updatedSelectedAnimal.copyWith(
          hearRate: event.heartRate,
          temperature: event.temperature,
          location: event.location,
        );
      }

      emit(currentState.copyWith(
        animals: updatedAnimals,
        filteredAnimals: updatedFilteredAnimals,
        selectedAnimal: updatedSelectedAnimal,
      ));
    }
  }

  @override
  Future<void> close() {
    _iotDataSubscription?.cancel();
    iotSyncService.dispose();
    return super.close();
  }
}
