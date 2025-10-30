import 'package:equatable/equatable.dart';

abstract class VaccineEvent extends Equatable {
  const VaccineEvent();

  @override
  List<Object?> get props => [];
}

class LoadVaccines extends VaccineEvent {
  final int medicalHistoryId;

  const LoadVaccines(this.medicalHistoryId);

  @override
  List<Object?> get props => [medicalHistoryId];
}

class CreateVaccineEvent extends VaccineEvent {
  final int medicalHistoryId;
  final String name;
  final String manufacturer;
  final String schema;

  const CreateVaccineEvent({
    required this.medicalHistoryId,
    required this.name,
    required this.manufacturer,
    required this.schema,
  });

  @override
  List<Object?> get props => [medicalHistoryId, name, manufacturer, schema];
}

class DeleteVaccineEvent extends VaccineEvent {
  final int vaccineId;
  final int medicalHistoryId;

  const DeleteVaccineEvent({
    required this.vaccineId,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [vaccineId, medicalHistoryId];
}
