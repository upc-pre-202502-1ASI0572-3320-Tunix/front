import 'package:equatable/equatable.dart';

enum Severity {
  leve(0, 'Leve'),
  moderado(1, 'Moderado'),
  grave(2, 'Grave');

  final int value;
  final String label;

  const Severity(this.value, this.label);

  static Severity fromValue(int value) {
    return Severity.values.firstWhere(
      (severity) => severity.value == value,
      orElse: () => Severity.leve,
    );
  }
}

class DiseaseDiagnosis extends Equatable {
  final int id;
  final Severity severity;
  final String notes;
  final DateTime diagnosedAt;
  final int medicalHistoryId;

  const DiseaseDiagnosis({
    required this.id,
    required this.severity,
    required this.notes,
    required this.diagnosedAt,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [id, severity, notes, diagnosedAt, medicalHistoryId];
}
