import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.urlPhoto,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      urlPhoto: json['urlPhoto'] as String?,
    );
  }

  Map<String, dynamic> toJsonForUpdate() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        if (urlPhoto != null) 'urlPhoto': urlPhoto,
      };
}
