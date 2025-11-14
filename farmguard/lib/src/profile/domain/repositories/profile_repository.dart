import 'dart:typed_data';

import '../entities/profile.dart';

abstract class ProfileRepository {
  /// Obtiene el perfil del usuario logueado usando el profileId guardado.
  Future<Profile> getProfile();

  /// Actualiza el perfil del usuario logueado.
  ///
  /// Todos los campos son opcionales; solo se enviará lo que venga distinto de null.
  /// [fileBytes] y [fileName] se usan para la foto de perfil (multipart/form-data).
  Future<Profile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    Uint8List? fileBytes,
    String? fileName,
  });

  /// Elimina el perfil del usuario logueado.
  Future<void> deleteProfile();
}
