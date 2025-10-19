import 'package:equatable/equatable.dart';
import '../../domain/entities/medical_history.dart';

abstract class MedicalHistoryState extends Equatable {
  const MedicalHistoryState();

  @override
  List<Object?> get props => [];
}

class MedicalHistoryInitial extends MedicalHistoryState {}

class MedicalHistoryLoading extends MedicalHistoryState {}

class MedicalHistoryLoaded extends MedicalHistoryState {
  final MedicalHistory medicalHistory;

  const MedicalHistoryLoaded(this.medicalHistory);

  @override
  List<Object?> get props => [medicalHistory];
}

class MedicalHistoryError extends MedicalHistoryState {
  final String message;

  const MedicalHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
