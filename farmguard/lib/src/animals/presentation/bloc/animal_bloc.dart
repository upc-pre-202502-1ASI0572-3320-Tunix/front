import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/animal.dart';
import '../../domain/usecases/get_animals_by_inventory.dart';
import '../../data/datasources/telemetry_signalr_service.dart';
import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final GetAnimalsByInventory getAnimalsByInventory;
  final TelemetrySignalRService telemetryService;
  StreamSubscription? _telemetrySubscription;

  AnimalBloc({
    required this.getAnimalsByInventory,
    required this.telemetryService,
  }) : super(AnimalInitial()) {
    on<LoadAnimals>(_onLoadAnimals);
    on<SelectAnimal>(_onSelectAnimal);
    on<FilterAnimals>(_onFilterAnimals);
    on<ConnectTelemetry>(_onConnectTelemetry);
    on<DisconnectTelemetry>(_onDisconnectTelemetry);
    on<TelemetryDataReceived>(_onTelemetryDataReceived);
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

  Future<void> _onConnectTelemetry(
    ConnectTelemetry event,
    Emitter<AnimalState> emit,
  ) async {
    try {
      // Conectar al hub de telemetría
      await telemetryService.connect(filter: event.filter);

      // Escuchar datos de telemetría entrantes
      _telemetrySubscription = telemetryService.telemetryStream.listen((telemetryData) {
        // Emitir evento con los datos recibidos
        add(TelemetryDataReceived(
          deviceId: telemetryData.deviceId,
          bpm: telemetryData.bpm,
          temperature: telemetryData.temperature,
          location: telemetryData.location,
        ));
      });

    } catch (e) {
    }
  }

  Future<void> _onDisconnectTelemetry(
    DisconnectTelemetry event,
    Emitter<AnimalState> emit,
  ) async {
    await _telemetrySubscription?.cancel();
    _telemetrySubscription = null;
    await telemetryService.disconnect();
  }

  void _onTelemetryDataReceived(
    TelemetryDataReceived event,
    Emitter<AnimalState> emit,
  ) {
    if (state is AnimalLoaded) {
      final currentState = state as AnimalLoaded;

      // Buscar el animal por deviceId
      final animalIndex = currentState.animals.indexWhere(
        (animal) => animal.deviceId == event.deviceId,
      );

      if (animalIndex == -1) {
        return;
      }

      final targetAnimal = currentState.animals[animalIndex];

      // Actualizar el animal con los datos de telemetría
      final updatedAnimals = List<Animal>.from(currentState.animals);
      updatedAnimals[animalIndex] = targetAnimal.copyWith(
        hearRate: event.bpm,
        temperature: event.temperature,
        location: event.location,
      );

      // Actualizar el animal en la lista filtrada
      final updatedFilteredAnimals = currentState.filteredAnimals.map((animal) {
        if (animal.deviceId == event.deviceId) {
          return animal.copyWith(
            hearRate: event.bpm,
            temperature: event.temperature,
            location: event.location,
          );
        }
        return animal;
      }).toList();

      // Actualizar el animal seleccionado si corresponde
      Animal? updatedSelectedAnimal = currentState.selectedAnimal;
      if (updatedSelectedAnimal != null && updatedSelectedAnimal.deviceId == event.deviceId) {
        updatedSelectedAnimal = updatedSelectedAnimal.copyWith(
          hearRate: event.bpm,
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
    _telemetrySubscription?.cancel();
    telemetryService.dispose();
    return super.close();
  }
}
