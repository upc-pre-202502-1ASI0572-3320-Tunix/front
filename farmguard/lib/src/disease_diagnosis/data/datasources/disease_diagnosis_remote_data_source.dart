import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/disease_diagnosis_model.dart';

abstract class DiseaseDiagnosisRemoteDataSource {
  Future<List<DiseaseDiagnosisModel>> getDiseaseDiagnosisByMedicalHistory(int medicalHistoryId);
  Future<DiseaseDiagnosisModel> createDiseaseDiagnosis(int medicalHistoryId, int severity, String notes, DateTime diagnosedAt);
  Future<void> deleteDiseaseDiagnosis(int id);
}

class DiseaseDiagnosisRemoteDataSourceImpl implements DiseaseDiagnosisRemoteDataSource {
  final ApiClient apiClient;

  DiseaseDiagnosisRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DiseaseDiagnosisModel>> getDiseaseDiagnosisByMedicalHistory(int medicalHistoryId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.diseaseDiagnosisByMedicalHistory(medicalHistoryId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => DiseaseDiagnosisModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load disease diagnoses - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DiseaseDiagnosisModel> createDiseaseDiagnosis(int medicalHistoryId, int severity, String notes, DateTime diagnosedAt) async {
    try {
      final requestBody = {
        'severity': severity.toString(),
        'notes': notes,
        'diagnosedAt': diagnosedAt.toIso8601String(),
      };

      final response = await apiClient.post(
        ApiConstants.createDiseaseDiagnosis(medicalHistoryId),
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final diagnosisData = response.data as Map<String, dynamic>;
        
        // Agregar medicalHistoryId si no viene en la respuesta
        if (!diagnosisData.containsKey('medicalHistoryId') || diagnosisData['medicalHistoryId'] == null) {
          diagnosisData['medicalHistoryId'] = medicalHistoryId;
        }
        
        return DiseaseDiagnosisModel.fromJson(diagnosisData);
      } else {
        throw Exception('Failed to create disease diagnosis - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDiseaseDiagnosis(int id) async {
    try {
      final response = await apiClient.delete(
        ApiConstants.deleteDiseaseDiagnosis(id),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete disease diagnosis - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
