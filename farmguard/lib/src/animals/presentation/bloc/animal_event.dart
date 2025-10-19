import 'package:equatable/equatable.dart';

abstract class AnimalEvent extends Equatable {
  const AnimalEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnimals extends AnimalEvent {
  final int inventoryId;

  const LoadAnimals(this.inventoryId);

  @override
  List<Object?> get props => [inventoryId];
}

class SelectAnimal extends AnimalEvent {
  final int animalId;

  const SelectAnimal(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class FilterAnimals extends AnimalEvent {
  final String? searchQuery;
  final String? specieFilter;

  const FilterAnimals({this.searchQuery, this.specieFilter});

  @override
  List<Object?> get props => [searchQuery, specieFilter];
}
