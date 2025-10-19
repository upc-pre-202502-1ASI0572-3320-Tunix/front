import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;
  ProfileRepositoryImpl(this.remote);

  @override
  Future<Profile> getProfile(int id) => remote.getProfile(id);

  @override
  Future<Profile> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? urlPhoto,
  }) {
    final model = ProfileModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      urlPhoto: urlPhoto,
    );
    return remote.updateProfile(id: id, payload: model);
  }
}
