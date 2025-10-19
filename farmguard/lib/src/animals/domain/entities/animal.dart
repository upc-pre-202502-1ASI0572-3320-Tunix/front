import 'package:equatable/equatable.dart';

class Animal extends Equatable {
  final int id;
  final String name;
  final String idAnimal;
  final String specie;
  final String urlIot;
  final String urlPhoto;
  final int inventoryId;
  final String location;
  final int hearRate;
  final double temperature;
  final bool sex; // true = macho, false = hembra
  final DateTime birthDate;

  const Animal({
    required this.id,
    required this.name,
    required this.idAnimal,
    required this.specie,
    required this.urlIot,
    required this.urlPhoto,
    required this.inventoryId,
    required this.location,
    required this.hearRate,
    required this.temperature,
    required this.sex,
    required this.birthDate,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        idAnimal,
        specie,
        urlIot,
        urlPhoto,
        inventoryId,
        location,
        hearRate,
        temperature,
        sex,
        birthDate,
      ];

  // Helper para obtener edad en años
  int get ageInYears {
    final now = DateTime.now();
    final age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      return age - 1;
    }
    return age;
  }

  // Helper para obtener sexo como texto
  String get sexText => sex ? 'Macho' : 'Hembra';
}
