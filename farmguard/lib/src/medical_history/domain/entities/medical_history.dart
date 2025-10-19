import 'package:equatable/equatable.dart';

class MedicalHistory extends Equatable {
  final int id;
  final int animalId;
  final String? animalName;
  final String? animalPhotoUrl;

  const MedicalHistory({
    required this.id,
    required this.animalId,
    this.animalName,
    this.animalPhotoUrl,
  });

  @override
  List<Object?> get props => [id, animalId, animalName, animalPhotoUrl];
  
  MedicalHistory copyWith({
    int? id,
    int? animalId,
    String? animalName,
    String? animalPhotoUrl,
  }) {
    return MedicalHistory(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      animalName: animalName ?? this.animalName,
      animalPhotoUrl: animalPhotoUrl ?? this.animalPhotoUrl,
    );
  }
}
