import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/animal.dart';

abstract class AnimalRepository {
  Future<Either<Failure, List<Animal>>> getAnimalsByInventory(int inventoryId);
}
