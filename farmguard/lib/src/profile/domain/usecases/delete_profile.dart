// lib/features/profile/domain/usecases/delete_profile.dart
import '../repositories/profile_repository.dart';

class DeleteProfile {
  final ProfileRepository repository;

  DeleteProfile(this.repository);

  Future<void> call() {
    return repository.deleteProfile();
  }
}
