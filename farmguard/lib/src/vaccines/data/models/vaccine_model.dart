import '../../domain/entities/vaccine.dart';

class VaccineModel extends Vaccine {
  const VaccineModel({
    required super.id,
    required super.name,
    required super.manufacturer,
    required super.schema,
    required super.medicalHistoryId,
  });

  factory VaccineModel.fromJson(Map<String, dynamic> json) {
    return VaccineModel(
      id: json['id'] as int,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String,
      schema: json['schema'] as String,
      medicalHistoryId: json['medicalHistoryId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'schema': schema,
      'medicalHistoryId': medicalHistoryId,
    };
  }

  Vaccine toEntity() {
    return Vaccine(
      id: id,
      name: name,
      manufacturer: manufacturer,
      schema: schema,
      medicalHistoryId: medicalHistoryId,
    );
  }
}
