import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/disease_diagnosis.dart';
import '../../domain/repositories/disease_diagnosis_repository.dart';
import '../datasources/disease_diagnosis_remote_data_source.dart';

class DiseaseDiagnosisRepositoryImpl implements DiseaseDiagnosisRepository {
  final DiseaseDiagnosisRemoteDataSource remoteDataSource;

  DiseaseDiagnosisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DiseaseDiagnosis>>> getDiseaseDiagnosisByMedicalHistory(int medicalHistoryId) async {
    try {
      final diagnoses = await remoteDataSource.getDiseaseDiagnosisByMedicalHistory(medicalHistoryId);
      return Right(diagnoses.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DiseaseDiagnosis>> createDiseaseDiagnosis(int medicalHistoryId, int severity, String notes, DateTime diagnosedAt) async {
    try {
      final diagnosis = await remoteDataSource.createDiseaseDiagnosis(medicalHistoryId, severity, notes, diagnosedAt);
      return Right(diagnosis.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDiseaseDiagnosis(int id) async {
    try {
      await remoteDataSource.deleteDiseaseDiagnosis(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
