import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/treatment.dart';
import '../repositories/treatment_repository.dart';

class GetTreatmentsByMedicalHistory {
  final TreatmentRepository repository;

  GetTreatmentsByMedicalHistory(this.repository);

  Future<Either<Failure, List<Treatment>>> call(int medicalHistoryId) async {
    return await repository.getTreatmentsByMedicalHistory(medicalHistoryId);
  }
}
