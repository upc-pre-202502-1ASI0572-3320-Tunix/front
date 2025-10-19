class Profile {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? urlPhoto; // opcional

  const Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.urlPhoto,
  });

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? urlPhoto,
  }) {
    return Profile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      urlPhoto: urlPhoto ?? this.urlPhoto,
    );
  }
}
