import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/animal.dart';
import '../../domain/usecases/get_animals_by_inventory.dart';
import 'animal_event.dart';
import 'animal_state.dart';

class AnimalBloc extends Bloc<AnimalEvent, AnimalState> {
  final GetAnimalsByInventory getAnimalsByInventory;

  AnimalBloc({
    required this.getAnimalsByInventory,
  }) : super(AnimalInitial()) {
    on<LoadAnimals>(_onLoadAnimals);
    on<SelectAnimal>(_onSelectAnimal);
    on<FilterAnimals>(_onFilterAnimals);
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
}
