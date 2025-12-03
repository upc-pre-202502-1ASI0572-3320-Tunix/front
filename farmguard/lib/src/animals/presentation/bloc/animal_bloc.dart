import 'dart:async';
import 'package:flutter/foundation.dart'; // Para debugPrint
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
        debugPrint('[AnimalBloc] Animales cargados: ${animals.length}');
        // Imprimir los deviceId/urlIot que tenemos en memoria para verificar
        for (var a in animals) {
          debugPrint('   Animal: ${a.name} | DeviceID(urlIot): "${a.deviceId}"');
        }
        
        if (animals.isEmpty) {
          emit(const AnimalLoaded(animals: []));
        } else {
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
      try {
        final selectedAnimal = currentState.filteredAnimals.firstWhere(
          (animal) => animal.id == event.animalId,
        );
        emit(currentState.copyWith(selectedAnimal: selectedAnimal));
      } catch (e) {
        debugPrint('[AnimalBloc] Error seleccionando animal: $e');
      }
    }
  }

  void _onFilterAnimals(
    FilterAnimals event,
    Emitter<AnimalState> emit,
  ) {
    if (state is AnimalLoaded) {
      final currentState = state as AnimalLoaded;
      List<Animal> filtered = currentState.animals;
      
      if (event.searchQuery != null && event.searchQuery!.length >= 3) {
        filtered = filtered.where((animal) {
          return animal.name.toLowerCase().contains(event.searchQuery!.toLowerCase());
        }).toList();
      }
      
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
      debugPrint('[AnimalBloc] Conectando a SignalR con filtro: "${event.filter}"');
      await telemetryService.connect(filter: event.filter);
      debugPrint('[AnimalBloc] Conexión completada, suscribiéndose al stream...');

      _telemetrySubscription?.cancel();
      _telemetrySubscription = telemetryService.telemetryStream.listen(
        (telemetryData) {
          debugPrint('[AnimalBloc] ✅ STREAM RECIBIDO: $telemetryData');
          add(TelemetryDataReceived(
            deviceId: telemetryData.deviceId,
            bpm: telemetryData.bpm,
            temperature: telemetryData.temperature,
            location: telemetryData.location,
          ));
        },
        onError: (error) {
          debugPrint('[AnimalBloc] ❌ ERROR en stream: $error');
        },
        onDone: () {
          debugPrint('[AnimalBloc] ⚠️ Stream terminado');
        },
      );
      debugPrint('[AnimalBloc] Suscripción al stream completada');
    } catch (e) {
      debugPrint('[AnimalBloc] Error crítico en conexión SignalR: $e');
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
    debugPrint('[AnimalBloc] 📊 Procesando actualización para DeviceID: "${event.deviceId}"');
    debugPrint('[AnimalBloc] 📊 BPM: ${event.bpm}, Temp: ${event.temperature}°C, Location: ${event.location}');
    
    if (state is AnimalLoaded) {
      final currentState = state as AnimalLoaded;
      debugPrint('[AnimalBloc] Estado actual es AnimalLoaded con ${currentState.animals.length} animales');

      // Buscamos ignorando mayúsculas/minúsculas y espacios
      final index = currentState.animals.indexWhere((a) => 
        a.deviceId.trim().toLowerCase() == event.deviceId.trim().toLowerCase()
      );

      if (index != -1) {
        final targetAnimal = currentState.animals[index];
        debugPrint('[AnimalBloc] ✅ Animal encontrado: ${targetAnimal.name}. Actualizando UI...');
        
        final updatedAnimal = targetAnimal.copyWith(
          hearRate: event.bpm,
          temperature: event.temperature,
          location: event.location,
        );

        // Crear nuevas listas para asegurar que Equatable detecte el cambio
        final updatedAnimals = List<Animal>.from(currentState.animals);
        updatedAnimals[index] = updatedAnimal;
        debugPrint('[AnimalBloc] 📝 Lista de animales actualizada. Nuevo BPM: ${updatedAnimal.hearRate}');

        // Actualizar listas filtradas
        final updatedFiltered = currentState.filteredAnimals.map((a) => 
          a.id == updatedAnimal.id ? updatedAnimal : a
        ).toList();
        debugPrint('[AnimalBloc] 📝 Lista filtrada actualizada: ${updatedFiltered.length} animales');

        // Siempre actualizar selectedAnimal si coincide
        Animal? updatedSelected = currentState.selectedAnimal;
        if (currentState.selectedAnimal?.id == updatedAnimal.id) {
          updatedSelected = updatedAnimal;
          debugPrint('[AnimalBloc] 🎯 Animal seleccionado actualizado: ${updatedAnimal.name} (BPM: ${updatedAnimal.hearRate})');
        }

        debugPrint('[AnimalBloc] 🚀 Emitiendo nuevo estado...');
        emit(AnimalLoaded(
          animals: updatedAnimals,
          filteredAnimals: updatedFiltered,
          selectedAnimal: updatedSelected,
          searchQuery: currentState.searchQuery,
          specieFilter: currentState.specieFilter,
        ));
        debugPrint('[AnimalBloc] ✅ Estado emitido exitosamente');
      } else {
        debugPrint('[AnimalBloc] ❌ No se encontró animal con DeviceID "${event.deviceId}"');
        debugPrint('[AnimalBloc] IDs disponibles: ${currentState.animals.map((a) => a.deviceId).toList()}');
      }
    } else {
      debugPrint('[AnimalBloc] ⚠️ Estado NO es AnimalLoaded, es: ${state.runtimeType}');
    }
  }

  @override
  Future<void> close() {
    _telemetrySubscription?.cancel();
    telemetryService.dispose();
    return super.close();
  }
}