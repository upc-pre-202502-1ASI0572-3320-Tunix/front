import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/treatment.dart';
import '../repositories/treatment_repository.dart';

class CreateTreatment {
  final TreatmentRepository repository;

  CreateTreatment(this.repository);

  Future<Either<Failure, Treatment>> call({
    required int medicalHistoryId,
    required String title,
    required String notes,
    required DateTime startDate,
    required bool status,
  }) async {
    return await repository.createTreatment(medicalHistoryId, title, notes, startDate, status);
  }
}
