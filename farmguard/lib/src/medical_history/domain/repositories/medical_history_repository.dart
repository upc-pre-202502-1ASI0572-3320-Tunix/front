import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medical_history.dart';

abstract class MedicalHistoryRepository {
  Future<Either<Failure, MedicalHistory>> getMedicalHistoryByAnimal(int animalId);
}
