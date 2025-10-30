import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vaccine.dart';
import '../../domain/repositories/vaccine_repository.dart';
import '../datasources/vaccine_remote_data_source.dart';

class VaccineRepositoryImpl implements VaccineRepository {
  final VaccineRemoteDataSource remoteDataSource;

  VaccineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Vaccine>>> getVaccinesByMedicalHistory(int medicalHistoryId) async {
    try {
      final vaccines = await remoteDataSource.getVaccinesByMedicalHistory(medicalHistoryId);
      return Right(vaccines.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vaccine>> createVaccine(int medicalHistoryId, String name, String manufacturer, String schema) async {
    try {
      final vaccine = await remoteDataSource.createVaccine(medicalHistoryId, name, manufacturer, schema);
      return Right(vaccine.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVaccine(int vaccineId) async {
    try {
      await remoteDataSource.deleteVaccine(vaccineId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
