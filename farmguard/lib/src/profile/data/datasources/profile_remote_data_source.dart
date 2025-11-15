import 'dart:convert';
import 'package:flutter/foundation.dart'; // <- para debugPrint
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/profile_model.dart';

String _redact(String? token) {
  if (token == null || token.isEmpty) return '<EMPTY>';
  if (token.length <= 10) return '${token.substring(0, 3)}***';
  return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
}

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(int id);
  Future<ProfileModel> updateProfile({ required int id, required ProfileModel payload });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  ProfileRemoteDataSourceImpl(this.client);

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  @override
  Future<ProfileModel> getProfile(int id) async {
    final token = await TokenStorage.getToken();
    debugPrint('[ProfileDS][GET] token: ${_redact(token)}'); // <-- LOG TOKEN
    if (token == null || token.isEmpty) {
      throw Exception('Auth token vacío: asegúrate de haber iniciado sesión.');
    }

    final url = _uri('/v1/profile/$id');
    debugPrint('[ProfileDS][GET] url: $url');                // <-- LOG URL
    final res = await client.get(url, headers: _headers(token));
    debugPrint('[ProfileDS][GET] status: ${res.statusCode}'); // <-- LOG STATUS

    if (res.statusCode == 200) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return ProfileModel.fromJson(map);
    }
    debugPrint('[ProfileDS][GET] body: ${res.body}');
    throw Exception('GET $url => ${res.statusCode}');
  }

  @override
  Future<ProfileModel> updateProfile({
    required int id,
    required ProfileModel payload,
  }) async {
    final token = await TokenStorage.getToken();
    debugPrint('[ProfileDS][PUT] token: ${_redact(token)}'); // <-- LOG TOKEN
    if (token == null || token.isEmpty) {
      throw Exception('Auth token vacío: asegúrate de haber iniciado sesión.');
    }

    final url = _uri('/v1/profile/$id');
    debugPrint('[ProfileDS][PUT] url: $url');                // <-- LOG URL
    debugPrint('[ProfileDS][PUT] body: ${payload.toJsonForUpdate()}');

    final res = await client.put(
      url,
      headers: _headers(token),
      body: json.encode(payload.toJsonForUpdate()),
    );
    debugPrint('[ProfileDS][PUT] status: ${res.statusCode}'); // <-- LOG STATUS

    if (res.statusCode == 200) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return ProfileModel.fromJson(map);
    }
    debugPrint('[ProfileDS][PUT] body: ${res.body}');
    throw Exception('PUT $url => ${res.statusCode}');
  }
}
