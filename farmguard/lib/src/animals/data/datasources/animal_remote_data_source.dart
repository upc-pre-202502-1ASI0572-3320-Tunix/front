import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/animal_model.dart';

abstract class AnimalRemoteDataSource {
  Future<List<AnimalModel>> getAnimalsByInventory(int inventoryId);
}

class AnimalRemoteDataSourceImpl implements AnimalRemoteDataSource {
  final ApiClient apiClient;

  AnimalRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AnimalModel>> getAnimalsByInventory(int inventoryId) async {
    final response = await apiClient.get(
      '${ApiConstants.animals}/inventory/$inventoryId',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => AnimalModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load animals');
    }
  }
}
