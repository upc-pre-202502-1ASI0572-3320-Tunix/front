import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal.dart';
import '../repositories/animal_repository.dart';

class GetAnimalsByInventory {
  final AnimalRepository repository;

  GetAnimalsByInventory(this.repository);

  Future<Either<Failure, List<Animal>>> call(int inventoryId) {
    return repository.getAnimalsByInventory(inventoryId);
  }
}
