import '../../domain/entities/iot_data.dart';

class IotDataModel extends IotData {
  const IotDataModel({
    required super.idAnimal,
    required super.heartRate,
    required super.temperature,
    required super.location,
    required super.id,
  });

  factory IotDataModel.fromJson(Map<String, dynamic> json) {
    return IotDataModel(
      idAnimal: json['idAnimal'] as int,
      heartRate: json['heartRate'] as int,
      temperature: (json['temperature'] as num).toDouble(), // Convertir a double
      location: json['location'] as String,
      id: json['id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idAnimal': idAnimal,
      'heartRate': heartRate,
      'temperature': temperature,
      'location': location,
      'id': id,
    };
  }
}
