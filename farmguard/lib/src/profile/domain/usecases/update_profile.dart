import 'dart:typed_data';

import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Profile> call({
    String? firstName,
    String? lastName,
    String? email,
    Uint8List? fileBytes,
    String? fileName,
  }) {
    return repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      fileBytes: fileBytes,
      fileName: fileName,
    );
  }
}
