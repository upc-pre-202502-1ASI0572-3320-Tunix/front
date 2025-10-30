import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/treatment.dart';

abstract class TreatmentRepository {
  Future<Either<Failure, List<Treatment>>> getTreatmentsByMedicalHistory(int medicalHistoryId);
  Future<Either<Failure, Treatment>> createTreatment(int medicalHistoryId, String title, String notes, DateTime startDate, bool status);
  Future<Either<Failure, void>> deleteTreatment(int id);
}
