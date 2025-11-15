import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/treatment.dart';
import '../../domain/repositories/treatment_repository.dart';
import '../datasources/treatment_remote_data_source.dart';

class TreatmentRepositoryImpl implements TreatmentRepository {
  final TreatmentRemoteDataSource remoteDataSource;

  TreatmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Treatment>>> getTreatmentsByMedicalHistory(int medicalHistoryId) async {
    try {
      final treatments = await remoteDataSource.getTreatmentsByMedicalHistory(medicalHistoryId);
      return Right(treatments.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Treatment>> createTreatment(int medicalHistoryId, String title, String notes, DateTime startDate, bool status) async {
    try {
      final treatment = await remoteDataSource.createTreatment(medicalHistoryId, title, notes, startDate, status);
      return Right(treatment.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTreatment(int id) async {
    try {
      await remoteDataSource.deleteTreatment(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
