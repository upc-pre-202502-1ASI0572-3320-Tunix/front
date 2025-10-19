/// Request para Sign Up
class SignUpRequest {
  final String username;
  final String password;
  final String firstName;
  final String lastName;
  final String email;
  final String? urlPhoto;

  SignUpRequest({
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.urlPhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'urlPhoto': urlPhoto ?? '',
    };
  }
}
