import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/iot_data_model.dart';

abstract class IotRemoteDataSource {
  Future<List<IotDataModel>> getIotData(String iotUrl);
}

class IotRemoteDataSourceImpl implements IotRemoteDataSource {
  final http.Client httpClient;

  IotRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<IotDataModel>> getIotData(String iotUrl) async {
    try {
      final response = await httpClient.get(
        Uri.parse(iotUrl),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data
            .map((json) => IotDataModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load IoT data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching IoT data: $e');
    }
  }
}