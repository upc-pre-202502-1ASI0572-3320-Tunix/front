import 'package:equatable/equatable.dart';
import '../../domain/entities/animal.dart';

abstract class AnimalState extends Equatable {
  const AnimalState();

  @override
  List<Object?> get props => [];
}

class AnimalInitial extends AnimalState {}

class AnimalLoading extends AnimalState {}

class AnimalLoaded extends AnimalState {
  final List<Animal> animals;
  final List<Animal> filteredAnimals;
  final Animal? selectedAnimal;
  final String? searchQuery;
  final String? specieFilter;

  const AnimalLoaded({
    required this.animals,
    List<Animal>? filteredAnimals,
    this.selectedAnimal,
    this.searchQuery,
    this.specieFilter,
  }) : filteredAnimals = filteredAnimals ?? animals;

  @override
  List<Object?> get props => [animals, filteredAnimals, selectedAnimal, searchQuery, specieFilter];

  AnimalLoaded copyWith({
    List<Animal>? animals,
    List<Animal>? filteredAnimals,
    Animal? selectedAnimal,
    String? searchQuery,
    String? specieFilter,
    bool clearFilters = false,
  }) {
    return AnimalLoaded(
      animals: animals ?? this.animals,
      filteredAnimals: filteredAnimals ?? this.filteredAnimals,
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      searchQuery: clearFilters ? null : (searchQuery ?? this.searchQuery),
      specieFilter: clearFilters ? null : (specieFilter ?? this.specieFilter),
    );
  }
}

class AnimalError extends AnimalState {
  final String message;

  const AnimalError(this.message);

  @override
  List<Object?> get props => [message];
}
