import 'package:equatable/equatable.dart';

abstract class TreatmentEvent extends Equatable {
  const TreatmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTreatments extends TreatmentEvent {
  final int medicalHistoryId;

  const LoadTreatments(this.medicalHistoryId);

  @override
  List<Object?> get props => [medicalHistoryId];
}

class CreateTreatmentEvent extends TreatmentEvent {
  final int medicalHistoryId;
  final String title;
  final String notes;
  final DateTime startDate;
  final bool status;

  const CreateTreatmentEvent({
    required this.medicalHistoryId,
    required this.title,
    required this.notes,
    required this.startDate,
    required this.status,
  });

  @override
  List<Object?> get props => [medicalHistoryId, title, notes, startDate, status];
}

class DeleteTreatmentEvent extends TreatmentEvent {
  final int id;

  const DeleteTreatmentEvent(this.id);

  @override
  List<Object?> get props => [id];
}
