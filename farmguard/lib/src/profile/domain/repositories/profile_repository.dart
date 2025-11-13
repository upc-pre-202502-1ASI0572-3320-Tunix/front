import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(int id);
  Future<Profile> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? urlPhoto,
  });
}
