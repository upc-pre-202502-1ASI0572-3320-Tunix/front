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

/// Evento para iniciar sincronización IoT de un animal
class StartIotSync extends AnimalEvent {
  final int animalId;
  final String iotUrl;

  const StartIotSync({required this.animalId, required this.iotUrl});

  @override
  List<Object?> get props => [animalId, iotUrl];
}

/// Evento para detener sincronización IoT
class StopIotSync extends AnimalEvent {
  const StopIotSync();
}

/// Evento para actualizar datos IoT de un animal
class UpdateAnimalIotData extends AnimalEvent {
  final int animalId;
  final int heartRate;
  final double temperature;
  final String location;

  const UpdateAnimalIotData({
    required this.animalId,
    required this.heartRate,
    required this.temperature,
    required this.location,
  });

  @override
  List<Object?> get props => [animalId, heartRate, temperature, location];
}
