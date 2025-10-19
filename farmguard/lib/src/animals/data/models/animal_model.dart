import '../../domain/entities/animal.dart';

class AnimalModel extends Animal {
  const AnimalModel({
    required super.id,
    required super.name,
    required super.idAnimal,
    required super.specie,
    required super.urlIot,
    required super.urlPhoto,
    required super.inventoryId,
    required super.location,
    required super.hearRate,
    required super.temperature,
    required super.sex,
    required super.birthDate,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as int,
      name: json['name'] as String,
      idAnimal: json['idAnimal'] as String,
      specie: json['specie'] as String,
      urlIot: json['urlIot'] as String,
      urlPhoto: json['urlPhoto'] as String,
      inventoryId: json['inventoryId'] as int,
      location: json['location'] as String,
      hearRate: json['hearRate'] as int,
      temperature: (json['temperature'] as num).toDouble(),
      sex: json['sex'] as bool,
      birthDate: DateTime.parse(json['birthDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'idAnimal': idAnimal,
      'specie': specie,
      'urlIot': urlIot,
      'urlPhoto': urlPhoto,
      'inventoryId': inventoryId,
      'location': location,
      'hearRate': hearRate,
      'temperature': temperature,
      'sex': sex,
      'birthDate': birthDate.toIso8601String(),
    };
  }
}
