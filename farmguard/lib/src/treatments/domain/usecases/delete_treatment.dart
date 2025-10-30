import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/treatment_repository.dart';

class DeleteTreatment {
  final TreatmentRepository repository;

  DeleteTreatment(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteTreatment(id);
  }
}
