import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repository;
  GetProfile(this.repository);

  Future<Profile> call(int id) => repository.getProfile(id);
}
