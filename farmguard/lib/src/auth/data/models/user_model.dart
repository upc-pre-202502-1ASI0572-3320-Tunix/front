import '../../domain/entities/user.dart';

/// Model de Usuario (Data Layer)
/// Extiende la Entity y agrega métodos de serialización
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.profileId,
    required super.inventoryId,
    super.firstName,
    super.lastName,
    super.email,
    super.urlPhoto,
  });

  /// Crear desde JSON (response de API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      profileId: json['profileId'] as int,
      inventoryId: json['inventoryId'] as int,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      urlPhoto: json['urlPhoto'] as String?,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profileId': profileId,
      'inventoryId': inventoryId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'urlPhoto': urlPhoto,
    };
  }

  /// Convertir a Entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      profileId: profileId,
      inventoryId: inventoryId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      urlPhoto: urlPhoto,
    );
  }
}
