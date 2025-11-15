import 'package:equatable/equatable.dart';
import '../../domain/entities/disease_diagnosis.dart';

abstract class DiseaseDiagnosisState extends Equatable {
  const DiseaseDiagnosisState();

  @override
  List<Object?> get props => [];
}

class DiseaseDiagnosisInitial extends DiseaseDiagnosisState {}

class DiseaseDiagnosisLoading extends DiseaseDiagnosisState {}

class DiseaseDiagnosisLoaded extends DiseaseDiagnosisState {
  final List<DiseaseDiagnosis> diagnoses;
  final int medicalHistoryId;

  const DiseaseDiagnosisLoaded({
    required this.diagnoses,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [diagnoses, medicalHistoryId];
}

class DiseaseDiagnosisError extends DiseaseDiagnosisState {
  final String message;

  const DiseaseDiagnosisError(this.message);

  @override
  List<Object?> get props => [message];
}

class DiseaseDiagnosisCreating extends DiseaseDiagnosisState {}

class DiseaseDiagnosisCreated extends DiseaseDiagnosisState {
  final DiseaseDiagnosis diagnosis;

  const DiseaseDiagnosisCreated(this.diagnosis);

  @override
  List<Object?> get props => [diagnosis];
}
