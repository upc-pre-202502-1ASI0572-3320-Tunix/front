import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class GetVaccinesByMedicalHistory {
  final VaccineRepository repository;

  GetVaccinesByMedicalHistory(this.repository);

  Future<Either<Failure, List<Vaccine>>> call(int medicalHistoryId) {
    return repository.getVaccinesByMedicalHistory(medicalHistoryId);
  }
}
