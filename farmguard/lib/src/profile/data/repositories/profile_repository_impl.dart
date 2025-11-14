import 'dart:typed_data';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Profile> getProfile() async {
    final ProfileModel model = await remoteDataSource.getProfile();
    // ProfileModel extiende Profile, así que se puede devolver tal cual.
    return model;
  }

  @override
  Future<Profile> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final ProfileModel model = await remoteDataSource.updateProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      fileBytes: fileBytes,
      fileName: fileName,
    );
    return model;
  }

  @override
  Future<void> deleteProfile() {
    return remoteDataSource.deleteProfile();
  }
}
