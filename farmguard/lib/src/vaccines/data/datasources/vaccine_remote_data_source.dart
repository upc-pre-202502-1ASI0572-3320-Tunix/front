import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/vaccine_model.dart';

abstract class VaccineRemoteDataSource {
  Future<List<VaccineModel>> getVaccinesByMedicalHistory(int medicalHistoryId);
  Future<VaccineModel> createVaccine(int medicalHistoryId, String name, String manufacturer, String schema);
  Future<void> deleteVaccine(int vaccineId);
}

class VaccineRemoteDataSourceImpl implements VaccineRemoteDataSource {
  final ApiClient apiClient;

  VaccineRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<VaccineModel>> getVaccinesByMedicalHistory(int medicalHistoryId) async {
    final response = await apiClient.get(
      ApiConstants.vaccinesByMedicalHistory(medicalHistoryId),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => VaccineModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load vaccines');
    }
  }

  @override
  Future<VaccineModel> createVaccine(int medicalHistoryId, String name, String manufacturer, String schema) async {
    try {
      final response = await apiClient.post(
        ApiConstants.createVaccine(medicalHistoryId),
        data: {
          'name': name,
          'manufacturer': manufacturer,
          'schema': schema,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Agregar medicalHistoryId a la respuesta si no viene
        final vaccineData = response.data as Map<String, dynamic>;
        if (!vaccineData.containsKey('medicalHistoryId') || vaccineData['medicalHistoryId'] == null) {
          vaccineData['medicalHistoryId'] = medicalHistoryId;
        }
        
        return VaccineModel.fromJson(vaccineData);
      } else {
        throw Exception('Failed to create vaccine - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteVaccine(int vaccineId) async {
    try {
      final response = await apiClient.delete(
        ApiConstants.deleteVaccine(vaccineId),
      );
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete vaccine - Status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
