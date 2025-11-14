import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_constants.dart';

class TokenStorage {
  // Mobile: Secure Storage
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Guardar token
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageConstants.authToken, token);
    } else {
      await _secureStorage.write(
        key: StorageConstants.authToken,
        value: token,
      );
    }
  }

  // Obtener token
  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageConstants.authToken);
    } else {
      return await _secureStorage.read(key: StorageConstants.authToken);
    }
  }

  static Future<String?> getProfileId() async { 
    if (kIsWeb) { 
      final prefs = await SharedPreferences.getInstance(); 
      return prefs.getString(StorageConstants.userId); 
      } else { 
        return await _secureStorage.read(key: StorageConstants.userId); 
        } 
  }
  
  

  // Guardar refresh token
  static Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageConstants.refreshToken, token);
    } else {
      await _secureStorage.write(
        key: StorageConstants.refreshToken,
        value: token,
      );
    }
  }

  // Obtener refresh token
  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageConstants.refreshToken);
    } else {
      return await _secureStorage.read(key: StorageConstants.refreshToken);
    }
  }

  // Limpiar todos los tokens
  static Future<void> clearTokens() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageConstants.authToken);
      await prefs.remove(StorageConstants.refreshToken);
      await prefs.remove(StorageConstants.userId);
      await prefs.remove(StorageConstants.userEmail);
    } else {
      await _secureStorage.delete(key: StorageConstants.authToken);
      await _secureStorage.delete(key: StorageConstants.refreshToken);
      await _secureStorage.delete(key: StorageConstants.userId);
      await _secureStorage.delete(key: StorageConstants.userEmail);
    }
  }

  // Verificar si hay token
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
