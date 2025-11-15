import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/disease_diagnosis.dart';
import '../repositories/disease_diagnosis_repository.dart';

class GetDiseaseDiagnosisByMedicalHistory {
  final DiseaseDiagnosisRepository repository;

  GetDiseaseDiagnosisByMedicalHistory(this.repository);

  Future<Either<Failure, List<DiseaseDiagnosis>>> call(int medicalHistoryId) async {
    return await repository.getDiseaseDiagnosisByMedicalHistory(medicalHistoryId);
  }
}
