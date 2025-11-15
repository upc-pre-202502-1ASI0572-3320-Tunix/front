import '../../domain/entities/treatment.dart';

class TreatmentModel {
  final int id;
  final String title;
  final String notes;
  final String startDate;
  final bool status;
  final int medicalHistoryId;

  TreatmentModel({
    required this.id,
    required this.title,
    required this.notes,
    required this.startDate,
    required this.status,
    required this.medicalHistoryId,
  });

  factory TreatmentModel.fromJson(Map<String, dynamic> json) {
    return TreatmentModel(
      id: json['id'] as int,
      title: json['title'] as String,
      notes: json['notes'] as String,
      startDate: json['startDate'] as String,
      status: json['status'] as bool,
      medicalHistoryId: json['medicalHistoryId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'startDate': startDate,
      'status': status,
      'medicalHistoryId': medicalHistoryId,
    };
  }

  Treatment toEntity() {
    return Treatment(
      id: id,
      title: title,
      notes: notes,
      startDate: DateTime.parse(startDate),
      status: status,
      medicalHistoryId: medicalHistoryId,
    );
  }
}
