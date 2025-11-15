import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vaccine.dart';
import '../repositories/vaccine_repository.dart';

class CreateVaccine {
  final VaccineRepository repository;

  CreateVaccine(this.repository);

  Future<Either<Failure, Vaccine>> call({
    required int medicalHistoryId,
    required String name,
    required String manufacturer,
    required String schema,
  }) {
    return repository.createVaccine(medicalHistoryId, name, manufacturer, schema);
  }
}
