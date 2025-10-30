import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/disease_diagnosis_repository.dart';

class DeleteDiseaseDiagnosis {
  final DiseaseDiagnosisRepository repository;

  DeleteDiseaseDiagnosis(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteDiseaseDiagnosis(id);
  }
}
