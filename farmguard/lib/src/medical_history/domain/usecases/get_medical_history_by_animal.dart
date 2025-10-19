import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medical_history.dart';
import '../repositories/medical_history_repository.dart';

class GetMedicalHistoryByAnimal {
  final MedicalHistoryRepository repository;

  GetMedicalHistoryByAnimal(this.repository);

  Future<Either<Failure, MedicalHistory>> call(int animalId) async {
    return await repository.getMedicalHistoryByAnimal(animalId);
  }
}
