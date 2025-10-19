import 'package:equatable/equatable.dart';

abstract class MedicalHistoryEvent extends Equatable {
  const MedicalHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicalHistory extends MedicalHistoryEvent {
  final int animalId;

  const LoadMedicalHistory(this.animalId);

  @override
  List<Object?> get props => [animalId];
}

class LoadAnimalDetails extends MedicalHistoryEvent {
  final String animalName;
  final String animalPhotoUrl;

  const LoadAnimalDetails(this.animalName, this.animalPhotoUrl);

  @override
  List<Object?> get props => [animalName, animalPhotoUrl];
}
