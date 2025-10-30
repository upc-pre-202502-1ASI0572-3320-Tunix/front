import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/treatment_model.dart';

abstract class TreatmentRemoteDataSource {
  Future<List<TreatmentModel>> getTreatmentsByMedicalHistory(int medicalHistoryId);
  Future<TreatmentModel> createTreatment(int medicalHistoryId, String title, String notes, DateTime startDate, bool status);
  Future<void> deleteTreatment(int id);
}

class TreatmentRemoteDataSourceImpl implements TreatmentRemoteDataSource {
  final ApiClient apiClient;

  TreatmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TreatmentModel>> getTreatmentsByMedicalHistory(int medicalHistoryId) async {
    try {
      final response = await apiClient.get(
        ApiConstants.treatmentsByMedicalHistory(medicalHistoryId),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => TreatmentModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load treatments - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TreatmentModel> createTreatment(int medicalHistoryId, String title, String notes, DateTime startDate, bool status) async {
    try {
      final requestBody = {
        'title': title,
        'notes': notes,
        'startDate': startDate.toIso8601String(),
        'status': status,
      };

      final response = await apiClient.post(
        ApiConstants.createTreatment(medicalHistoryId),
        data: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final treatmentData = response.data as Map<String, dynamic>;
        
        // Agregar medicalHistoryId si no viene en la respuesta
        if (!treatmentData.containsKey('medicalHistoryId') || treatmentData['medicalHistoryId'] == null) {
          treatmentData['medicalHistoryId'] = medicalHistoryId;
        }
        
        return TreatmentModel.fromJson(treatmentData);
      } else {
        throw Exception('Failed to create treatment - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTreatment(int id) async {
    try {
      final response = await apiClient.delete(
        ApiConstants.deleteTreatment(id),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete treatment - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
