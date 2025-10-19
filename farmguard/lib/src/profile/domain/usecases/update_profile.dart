import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;
  UpdateProfile(this.repository);

  Future<Profile> call({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? urlPhoto,
  }) {
    return repository.updateProfile(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      urlPhoto: urlPhoto,
    );
  }
}
