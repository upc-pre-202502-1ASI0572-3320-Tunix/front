import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/vaccine_repository.dart';

class DeleteVaccine {
  final VaccineRepository repository;

  DeleteVaccine(this.repository);

  Future<Either<Failure, void>> call(int vaccineId) async {
    return await repository.deleteVaccine(vaccineId);
  }
}
