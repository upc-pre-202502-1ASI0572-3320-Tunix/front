import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../.././profile/domain/entities/profile.dart';
import '../.././profile/domain/usecases/get_profile.dart';
import '../.././profile/domain/usecases/update_profile.dart';

class SettingsController extends ChangeNotifier {
  final GetProfile getProfileUC;
  final UpdateProfile updateProfileUC;
  final int profileId;

  // Estado editable
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  ImageProvider? avatar;

  bool _isSaving = false;
  bool _hasChanges = false;
  bool _isLoading = false;
  String? _lastError;
  Profile? _loaded;

  bool get isSaving => _isSaving;
  bool get hasChanges => _hasChanges;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  Profile? get profile => _loaded;

  SettingsController({
    required this.getProfileUC,
    required this.updateProfileUC,
    required this.profileId,
  }) {
    for (final c in [nameCtrl, lastNameCtrl, emailCtrl]) {
      c.addListener(() {
        _hasChanges = true;
        notifyListeners();
      });
    }
  }

  Future<void> load() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();
    try {
      final p = await getProfileUC(profileId);
      _loaded = p;
      nameCtrl.text = p.firstName;
      lastNameCtrl.text = p.lastName;
      emailCtrl.text = p.email;
      if (p.urlPhoto != null && p.urlPhoto!.isNotEmpty) {
        avatar = NetworkImage(p.urlPhoto!);
      }
      _hasChanges = false;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAvatarFromFile(File file) {
    avatar = FileImage(file);
    _hasChanges = true;
    notifyListeners();
  }

  void setAvatarFromBytes(Uint8List bytes) {
  avatar = MemoryImage(bytes);
  _hasChanges = true;
  notifyListeners();
}

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    _isSaving = true;
    _lastError = null;
    notifyListeners();

    try {
      // 🔧 Determinar la URL a enviar
      String? urlPhotoToSend;
      if (avatar is NetworkImage) {
        urlPhotoToSend = (avatar as NetworkImage).url;
      } else {
        // Si no hay nueva imagen, usa la anterior
        urlPhotoToSend = _loaded?.urlPhoto ?? '';
      }

      final updated = await updateProfileUC(
        id: profileId,
        firstName: nameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        urlPhoto: urlPhotoToSend,
      );

      _loaded = updated;
      _hasChanges = false;
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSaving = false;
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
