import 'dart:typed_data';

/// Request para Sign Up
class SignUpRequest {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final Uint8List? photoBytes;
  final String? photoFileName;

  SignUpRequest({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoBytes,
    this.photoFileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
}
