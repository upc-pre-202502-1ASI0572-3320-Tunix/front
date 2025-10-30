import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vaccine.dart';

abstract class VaccineRepository {
  Future<Either<Failure, List<Vaccine>>> getVaccinesByMedicalHistory(int medicalHistoryId);
  Future<Either<Failure, Vaccine>> createVaccine(int medicalHistoryId, String name, String manufacturer, String schema);
  Future<Either<Failure, void>> deleteVaccine(int vaccineId);
}
