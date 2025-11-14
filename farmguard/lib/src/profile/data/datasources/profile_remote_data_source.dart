import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // debugPrint
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
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    Uint8List? fileBytes,
    String? fileName,
  });

  Future<void> deleteProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSourceImpl(this.client);

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Map<String, String> _jsonHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<String> _getRequiredToken() async {
    final token = await TokenStorage.getToken();
    debugPrint('[ProfileDS] token: ${_redact(token)}');

    if (token == null || token.isEmpty) {
      throw Exception('Auth token vacío: asegúrate de haber iniciado sesión.');
    }
    return token;
  }

  Future<int> _getRequiredProfileId() async {
    final idStr = await TokenStorage.getProfileId();
    debugPrint('[ProfileDS] stored profileId: $idStr');

    if (idStr == null || idStr.isEmpty) {
      throw Exception(
        'profileId vacío en storage. Asegúrate de guardarlo al iniciar sesión/registro.',
      );
    }

    final id = int.tryParse(idStr);
    if (id == null) {
      throw Exception(
        'profileId inválido en storage. Valor actual: "$idStr" (no es int).',
      );
    }

    return id;
  }

  @override
  Future<ProfileModel> getProfile() async {
    final token = await _getRequiredToken();
    final id = await _getRequiredProfileId();

    // Swagger: GET /api/v1/profile/{idProfile}
    final url = _uri('/v1/profile/$id');
    debugPrint('[ProfileDS][GET] url: $url');

    final res = await client.get(
      url,
      headers: _jsonHeaders(token),
    );

    debugPrint('[ProfileDS][GET] status: ${res.statusCode}');

    if (res.statusCode == 200) {
      final map = json.decode(res.body) as Map<String, dynamic>;
      return ProfileModel.fromJson(map);
    }

    debugPrint('[ProfileDS][GET] body: ${res.body}');
    throw Exception('GET $url => ${res.statusCode}');
  }


@override
Future<ProfileModel> updateProfile({
  String? firstName,
  String? lastName,
  String? email,
  Uint8List? fileBytes,
  String? fileName,
}) async {
  final token = await _getRequiredToken();
  final id = await _getRequiredProfileId();

  final url = _uri('/v1/profile/$id');
  debugPrint('[ProfileDS][PUT] url: $url');

  final request = http.MultipartRequest('PUT', url);

  if (firstName != null) {
    request.fields['FirstName'] = firstName;
  }
  if (lastName != null) {
    request.fields['LastName'] = lastName;
  }
  if (email != null) {
    request.fields['Email'] = email;
  }

  // 👇 Siempre deberíamos tener fileBytes gracias al controller.
  // Si por alguna razón es null, es mejor lanzar un error explícito.
  if (fileBytes == null) {
    throw Exception(
      'No hay bytes de imagen para enviar. El backend requiere siempre un archivo "file".',
    );
  }

  request.files.add(
    http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName ?? 'avatar.jpg',
    ),
  );

  request.headers['Authorization'] = 'Bearer $token';

  debugPrint('[ProfileDS][PUT] fields: ${request.fields}');
  debugPrint('[ProfileDS][PUT] hasFile: ${fileBytes.isNotEmpty}');

  final streamed = await client.send(request);
  final res = await http.Response.fromStream(streamed);

  debugPrint('[ProfileDS][PUT] status: ${res.statusCode}');
  debugPrint('[ProfileDS][PUT] body: ${res.body}');

  if (res.statusCode == 200) {
    final map = json.decode(res.body) as Map<String, dynamic>;
    return ProfileModel.fromJson(map);
  }

  throw Exception('PUT $url => ${res.statusCode}');
}



  @override
  Future<void> deleteProfile() async {
    final token = await _getRequiredToken();
    final id = await _getRequiredProfileId();

    // Swagger: DELETE /api/v1/profile/{profileId}
    final url = _uri('/v1/profile/$id');
    debugPrint('[ProfileDS][DELETE] url: $url');

    final res = await client.delete(
      url,
      headers: _jsonHeaders(token),
    );

    debugPrint('[ProfileDS][DELETE] status: ${res.statusCode}');
    if (res.statusCode != 200) {
      debugPrint('[ProfileDS][DELETE] body: ${res.body}');
      throw Exception('DELETE $url => ${res.statusCode}');
    }
  }
}
