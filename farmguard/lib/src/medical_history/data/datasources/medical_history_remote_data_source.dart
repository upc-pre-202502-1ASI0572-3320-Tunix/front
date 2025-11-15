import '../../../../core/network/api_client.dart';
import '../models/medical_history_model.dart';

abstract class MedicalHistoryRemoteDataSource {
  Future<MedicalHistoryModel> getMedicalHistoryByAnimal(int animalId);
}

class MedicalHistoryRemoteDataSourceImpl implements MedicalHistoryRemoteDataSource {
  final ApiClient apiClient;

  MedicalHistoryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MedicalHistoryModel> getMedicalHistoryByAnimal(int animalId) async {
    final response = await apiClient.get('/medicalhistory/by-animal/$animalId');
    
    if (response.statusCode == 200) {
      return MedicalHistoryModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load medical history');
    }
  }
}
