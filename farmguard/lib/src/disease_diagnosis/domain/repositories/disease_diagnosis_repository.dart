import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/disease_diagnosis.dart';

abstract class DiseaseDiagnosisRepository {
  Future<Either<Failure, List<DiseaseDiagnosis>>> getDiseaseDiagnosisByMedicalHistory(int medicalHistoryId);
  Future<Either<Failure, DiseaseDiagnosis>> createDiseaseDiagnosis(int medicalHistoryId, int severity, String notes, DateTime diagnosedAt);
  Future<Either<Failure, void>> deleteDiseaseDiagnosis(int id);
}
