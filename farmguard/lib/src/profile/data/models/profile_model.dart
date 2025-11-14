import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    String? urlPhoto,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          urlPhoto: urlPhoto,
        );

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      urlPhoto: json['urlPhoto'] as String?, // 👈 IMPORTANTE
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'urlPhoto': urlPhoto,
    };
  }
}
