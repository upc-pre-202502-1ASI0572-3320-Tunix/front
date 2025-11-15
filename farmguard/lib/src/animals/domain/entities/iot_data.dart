import 'package:equatable/equatable.dart';

/// Entidad que representa los datos recibidos desde el dispositivo IoT
class IotData extends Equatable {
  final int idAnimal;
  final int heartRate;
  final double temperature; // Cambiado a double para soportar decimales
  final String location;
  final String id; // ID del registro (lo ignoramos, pero lo mantenemos por si acaso)

  const IotData({
    required this.idAnimal,
    required this.heartRate,
    required this.temperature,
    required this.location,
    required this.id,
  });

  @override
  List<Object?> get props => [idAnimal, heartRate, temperature, location, id];
}
