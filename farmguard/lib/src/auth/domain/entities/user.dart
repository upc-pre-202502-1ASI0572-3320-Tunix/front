import 'package:equatable/equatable.dart';

/// Entity de Usuario (Domain Layer)
/// Representa la lógica de negocio pura, sin depender de frameworks
class User extends Equatable {
  final int id;
  final String username;
  final int profileId;
  final int inventoryId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? urlPhoto;

  const User({
    required this.id,
    required this.username,
    required this.profileId,
    required this.inventoryId,
    this.firstName,
    this.lastName,
    this.email,
    this.urlPhoto,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        profileId,
        inventoryId,
        firstName,
        lastName,
        email,
        urlPhoto,
      ];
}
