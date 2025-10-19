import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medical_history.dart';
import '../../domain/repositories/medical_history_repository.dart';
import '../datasources/medical_history_remote_data_source.dart';

class MedicalHistoryRepositoryImpl implements MedicalHistoryRepository {
  final MedicalHistoryRemoteDataSource remoteDataSource;

  MedicalHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MedicalHistory>> getMedicalHistoryByAnimal(int animalId) async {
    try {
      final medicalHistory = await remoteDataSource.getMedicalHistoryByAnimal(animalId);
      return Right(medicalHistory);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
