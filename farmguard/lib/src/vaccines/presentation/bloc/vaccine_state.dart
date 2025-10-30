import 'package:equatable/equatable.dart';
import '../../domain/entities/vaccine.dart';

abstract class VaccineState extends Equatable {
  const VaccineState();

  @override
  List<Object?> get props => [];
}

class VaccineInitial extends VaccineState {}

class VaccineLoading extends VaccineState {}

class VaccineLoaded extends VaccineState {
  final List<Vaccine> vaccines;
  final int medicalHistoryId;

  const VaccineLoaded({
    required this.vaccines,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [vaccines, medicalHistoryId];
}

class VaccineError extends VaccineState {
  final String message;

  const VaccineError(this.message);

  @override
  List<Object?> get props => [message];
}

class VaccineCreating extends VaccineState {}

class VaccineCreated extends VaccineState {
  final Vaccine vaccine;

  const VaccineCreated(this.vaccine);

  @override
  List<Object?> get props => [vaccine];
}

class VaccineDeleting extends VaccineState {}

class VaccineDeleted extends VaccineState {}
