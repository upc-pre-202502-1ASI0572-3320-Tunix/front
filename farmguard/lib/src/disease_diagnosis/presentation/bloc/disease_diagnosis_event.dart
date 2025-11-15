import 'package:equatable/equatable.dart';

abstract class DiseaseDiagnosisEvent extends Equatable {
  const DiseaseDiagnosisEvent();

  @override
  List<Object?> get props => [];
}

class LoadDiseaseDiagnoses extends DiseaseDiagnosisEvent {
  final int medicalHistoryId;

  const LoadDiseaseDiagnoses(this.medicalHistoryId);

  @override
  List<Object?> get props => [medicalHistoryId];
}

class CreateDiseaseDiagnosisEvent extends DiseaseDiagnosisEvent {
  final int medicalHistoryId;
  final int severity;
  final String notes;
  final DateTime diagnosedAt;

  const CreateDiseaseDiagnosisEvent({
    required this.medicalHistoryId,
    required this.severity,
    required this.notes,
    required this.diagnosedAt,
  });

  @override
  List<Object?> get props => [medicalHistoryId, severity, notes, diagnosedAt];
}

class DeleteDiseaseDiagnosisEvent extends DiseaseDiagnosisEvent {
  final int id;

  const DeleteDiseaseDiagnosisEvent(this.id);

  @override
  List<Object?> get props => [id];
}
