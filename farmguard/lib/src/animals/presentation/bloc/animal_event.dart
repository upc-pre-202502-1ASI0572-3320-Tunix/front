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

/// Evento para conectar a SignalR telemetry hub
class ConnectTelemetry extends AnimalEvent {
  final String filter;

  const ConnectTelemetry({this.filter = 'collar'});

  @override
  List<Object?> get props => [filter];
}

/// Evento para desconectar SignalR telemetry hub
class DisconnectTelemetry extends AnimalEvent {
  const DisconnectTelemetry();
}

/// Evento cuando se reciben datos de telemetría desde SignalR
class TelemetryDataReceived extends AnimalEvent {
  final String deviceId;
  final int bpm;
  final double temperature;
  final String location;

  const TelemetryDataReceived({
    required this.deviceId,
    required this.bpm,
    required this.temperature,
    required this.location,
  });

  @override
  List<Object?> get props => [deviceId, bpm, temperature, location];
}
