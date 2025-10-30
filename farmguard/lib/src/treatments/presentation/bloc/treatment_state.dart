import 'package:equatable/equatable.dart';
import '../../domain/entities/treatment.dart';

abstract class TreatmentState extends Equatable {
  const TreatmentState();

  @override
  List<Object?> get props => [];
}

class TreatmentInitial extends TreatmentState {}

class TreatmentLoading extends TreatmentState {}

class TreatmentLoaded extends TreatmentState {
  final List<Treatment> treatments;
  final int medicalHistoryId;

  const TreatmentLoaded({
    required this.treatments,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [treatments, medicalHistoryId];
}

class TreatmentError extends TreatmentState {
  final String message;

  const TreatmentError(this.message);

  @override
  List<Object?> get props => [message];
}

class TreatmentCreating extends TreatmentState {}

class TreatmentCreated extends TreatmentState {
  final Treatment treatment;

  const TreatmentCreated(this.treatment);

  @override
  List<Object?> get props => [treatment];
}
