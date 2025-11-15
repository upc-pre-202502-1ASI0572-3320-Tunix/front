import 'package:equatable/equatable.dart';

class Treatment extends Equatable {
  final int id;
  final String title;
  final String notes;
  final DateTime startDate;
  final bool status;
  final int medicalHistoryId;

  const Treatment({
    required this.id,
    required this.title,
    required this.notes,
    required this.startDate,
    required this.status,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [id, title, notes, startDate, status, medicalHistoryId];
}
