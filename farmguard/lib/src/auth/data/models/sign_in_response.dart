import 'user_model.dart';

/// Response de Sign In
class SignInResponse {
  final int id;
  final String username;
  final int profileId;
  final int inventoryId;
  final String token;

  SignInResponse({
    required this.id,
    required this.username,
    required this.profileId,
    required this.inventoryId,
    required this.token,
  });

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    return SignInResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      profileId: json['profileId'] as int,
      inventoryId: json['inventoryId'] as int,
      token: json['token'] as String,
    );
  }

  /// Convertir a UserModel
  UserModel toUserModel() {
    return UserModel(
      id: id,
      username: username,
      profileId: profileId,
      inventoryId: inventoryId,
    );
  }
}
