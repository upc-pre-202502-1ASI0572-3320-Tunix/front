import '../../domain/entities/disease_diagnosis.dart';

class DiseaseDiagnosisModel {
  final int id;
  final int severity;
  final String notes;
  final String diagnosedAt;
  final int medicalHistoryId;

  DiseaseDiagnosisModel({
    required this.id,
    required this.severity,
    required this.notes,
    required this.diagnosedAt,
    required this.medicalHistoryId,
  });

  factory DiseaseDiagnosisModel.fromJson(Map<String, dynamic> json) {
    return DiseaseDiagnosisModel(
      id: json['id'] as int,
      severity: json['severity'] as int,
      notes: json['notes'] as String,
      diagnosedAt: json['diagnosedAt'] as String,
      medicalHistoryId: json['medicalHistoryId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'severity': severity,
      'notes': notes,
      'diagnosedAt': diagnosedAt,
      'medicalHistoryId': medicalHistoryId,
    };
  }

  DiseaseDiagnosis toEntity() {
    return DiseaseDiagnosis(
      id: id,
      severity: Severity.fromValue(severity),
      notes: notes,
      diagnosedAt: DateTime.parse(diagnosedAt),
      medicalHistoryId: medicalHistoryId,
    );
  }
}
