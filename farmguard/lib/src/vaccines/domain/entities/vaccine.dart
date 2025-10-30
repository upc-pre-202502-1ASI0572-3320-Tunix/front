import 'package:equatable/equatable.dart';

class Vaccine extends Equatable {
  final int id;
  final String name;
  final String manufacturer;
  final String schema;
  final int medicalHistoryId;

  const Vaccine({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.schema,
    required this.medicalHistoryId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        manufacturer,
        schema,
        medicalHistoryId,
      ];
}
