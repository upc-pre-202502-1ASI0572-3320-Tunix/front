import '../../domain/entities/medical_history.dart';

class MedicalHistoryModel extends MedicalHistory {
  const MedicalHistoryModel({
    required super.id,
    required super.animalId,
    super.animalName,
    super.animalPhotoUrl,
  });

  factory MedicalHistoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalHistoryModel(
      id: json['id'] as int,
      animalId: json['animalId'] as int,
      animalName: json['animalName'] as String?,
      animalPhotoUrl: json['animalPhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'animalName': animalName,
      'animalPhotoUrl': animalPhotoUrl,
    };
  }
}
