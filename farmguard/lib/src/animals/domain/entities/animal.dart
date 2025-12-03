import 'package:equatable/equatable.dart';

class Animal extends Equatable {
  final int id;
  final String name;
  final String idAnimal;
  final String specie;
  final String deviceId;
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
    required this.deviceId,
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
        deviceId,
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

  // copyWith para crear copias con datos actualizados
  Animal copyWith({
    int? id,
    String? name,
    String? idAnimal,
    String? specie,
    String? deviceId,
    String? urlPhoto,
    int? inventoryId,
    String? location,
    int? hearRate,
    double? temperature,
    bool? sex,
    DateTime? birthDate,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      idAnimal: idAnimal ?? this.idAnimal,
      specie: specie ?? this.specie,
      deviceId: deviceId ?? this.deviceId,
      urlPhoto: urlPhoto ?? this.urlPhoto,
      inventoryId: inventoryId ?? this.inventoryId,
      location: location ?? this.location,
      hearRate: hearRate ?? this.hearRate,
      temperature: temperature ?? this.temperature,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
