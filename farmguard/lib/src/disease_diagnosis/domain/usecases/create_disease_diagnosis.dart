import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/disease_diagnosis.dart';
import '../repositories/disease_diagnosis_repository.dart';

class CreateDiseaseDiagnosis {
  final DiseaseDiagnosisRepository repository;

  CreateDiseaseDiagnosis(this.repository);

  Future<Either<Failure, DiseaseDiagnosis>> call({
    required int medicalHistoryId,
    required int severity,
    required String notes,
    required DateTime diagnosedAt,
  }) async {
    return await repository.createDiseaseDiagnosis(medicalHistoryId, severity, notes, diagnosedAt);
  }
}
