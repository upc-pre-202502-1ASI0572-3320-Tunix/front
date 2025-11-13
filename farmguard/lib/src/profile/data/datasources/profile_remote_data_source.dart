// data/datasources/profile_remote_data_source.dart
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
  /// Obtiene el perfil del usuario logueado usando el profileId guardado
  Future<ProfileModel> getProfile();

  /// Actualiza el perfil del usuario logueado
  ///
  /// Todos los campos son opcionales; solo se manda lo que cambie.
  /// [fileBytes] y [fileName] son para la foto de perfil.
  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    Uint8List? fileBytes,
    String? fileName,
  });

  /// Elimina el perfil del usuario logueado
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

  Future<int> _getRequiredProfileId() async {
    final idStr = await TokenStorage.getProfileId();
    debugPrint('[ProfileDS] stored profileId: $idStr');

    if (idStr == null || idStr.isEmpty) {
      throw Exception(
        'profileId vacío en storage. Asegúrate de guardar el ID del perfil al iniciar sesión/registro.',
      );
    }

    final id = int.tryParse(idStr);
    if (id == null) {
      throw Exception(
        'profileId inválido en storage. Valor actual: "$idStr" (no es un int).',
      );
    }
    return id;
  }

  Future<String> _getRequiredToken() async {
    final token = await TokenStorage.getToken();
    debugPrint('[ProfileDS] token: ${_redact(token)}');

    if (token == null || token.isEmpty) {
      throw Exception(
        'Auth token vacío: asegúrate de haber iniciado sesión.',
      );
    }
    return token;
  }

  @override
  Future<ProfileModel> getProfile() async {
    final token = await _getRequiredToken();
    final id = await _getRequiredProfileId();

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

    // PUT /api/v1/profile/{profileId}  multipart/form-data
    final request = http.MultipartRequest('PUT', url);

    // Swagger muestra FirstName, LastName, Email, file
    if (firstName != null) {
      request.fields['FirstName'] = firstName;
    }
    if (lastName != null) {
      request.fields['LastName'] = lastName;
    }
    if (email != null) {
      request.fields['Email'] = email;
    }
    if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName ?? 'avatar.jpg',
        ),
      );
    }

    request.headers['Authorization'] = 'Bearer $token';
    // NO seteamos Content-Type, lo maneja MultipartRequest

    debugPrint('[ProfileDS][PUT] fields: ${request.fields}');
    debugPrint('[ProfileDS][PUT] hasFile: ${fileBytes != null}');

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
