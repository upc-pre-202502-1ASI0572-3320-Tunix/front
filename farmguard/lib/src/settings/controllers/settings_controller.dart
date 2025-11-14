// lib/features/settings/presentation/controllers/settings_controller.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/storage/token_storage.dart';
import '../../profile/domain/entities/profile.dart';
import '../../profile/domain/usecases/get_profile.dart';
import '../../profile/domain/usecases/update_profile.dart';
import '../../profile/domain/usecases/delete_profile.dart';

class SettingsController extends ChangeNotifier {
  final GetProfile getProfileUC;
  final UpdateProfile updateProfileUC;
  final DeleteProfile deleteProfileUC;

  // Estado editable
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  ImageProvider? avatar;

  // Para reenviar la imagen al backend
  Uint8List? _avatarBytes;
  String? _avatarFileName;

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _lastError;
  Profile? _loaded;

  bool get isSaving => _isSaving;
  bool get hasChanges => _hasChanges;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get lastError => _lastError;
  Profile? get profile => _loaded;

  SettingsController({
    required this.getProfileUC,
    required this.updateProfileUC,
    required this.deleteProfileUC,
  }) {
    for (final c in [nameCtrl, lastNameCtrl, emailCtrl]) {
      c.addListener(() {
        _hasChanges = true;
        notifyListeners();
      });
    }
  }

  // =============================================================
  // Cargar perfil + imagen actual (y bytes)
  // =============================================================
  Future<void> load() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final p = await getProfileUC();
      _loaded = p;

      nameCtrl.text = p.firstName;
      lastNameCtrl.text = p.lastName;
      emailCtrl.text = p.email;

      _avatarBytes = null;
      _avatarFileName = null;
      avatar = null;

      if (p.urlPhoto != null && p.urlPhoto!.isNotEmpty) {
        final url = p.urlPhoto!;
        avatar = NetworkImage(url);

        try {
          final uri = Uri.parse(url);
          final res = await http.get(uri);

          if (res.statusCode == 200) {
            _avatarBytes = res.bodyBytes;
            _avatarFileName = uri.pathSegments.isNotEmpty
                ? uri.pathSegments.last
                : 'avatar.jpg';
          } else {
            debugPrint(
              '[SettingsController] No se pudieron obtener bytes de la imagen: ${res.statusCode}',
            );
          }
        } catch (e) {
          debugPrint('[SettingsController] Error obteniendo foto: $e');
        }
      }

      _hasChanges = false;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =============================================================
  // Asignar foto desde File (mobile)
  // =============================================================
  Future<void> setAvatarFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final fileName = file.path.split(Platform.pathSeparator).last;

    _avatarBytes = bytes;
    _avatarFileName = fileName;

    avatar = FileImage(file);
    _hasChanges = true;
    notifyListeners();
  }

  // =============================================================
  // Asignar foto desde bytes (web)
  // =============================================================
  void setAvatarFromBytes(
    Uint8List bytes, {
    String fileName = 'avatar.jpg',
  }) {
    _avatarBytes = bytes;
    _avatarFileName = fileName;

    avatar = MemoryImage(bytes);
    _hasChanges = true;
    notifyListeners();
  }

  // =============================================================
  // Guardar cambios
  // =============================================================
  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    _isSaving = true;
    _lastError = null;
    notifyListeners();

    try {
      final updated = await updateProfileUC(
        firstName: nameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        fileBytes: _avatarBytes,
        fileName: _avatarFileName,
      );

      _loaded = updated;

      if (updated.urlPhoto != null && updated.urlPhoto!.isNotEmpty) {
        avatar = NetworkImage(updated.urlPhoto!);
      }

      _hasChanges = false;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // =============================================================
  // Borrar perfil + limpiar sesión local (tokens)
  // =============================================================
  Future<bool> deleteAccount() async {
    _isDeleting = true;
    _lastError = null;
    notifyListeners();

    try {
      await deleteProfileUC();          // DELETE backend
      await TokenStorage.clearTokens(); // limpiar tokens localmente
      _loaded = null;
      return true;
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }
}
