import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/animal.dart';
import '../../domain/repositories/animal_repository.dart';
import '../datasources/animal_remote_data_source.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalRemoteDataSource remoteDataSource;

  AnimalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Animal>>> getAnimalsByInventory(int inventoryId) async {
    try {
      final animals = await remoteDataSource.getAnimalsByInventory(inventoryId);
      return Right(animals);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
