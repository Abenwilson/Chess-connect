class AppUser {
  final String uid;
  final String name;
  final String email;
  final String profession;
  final String role; // Add role field

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profession,
    required this.role, // Add role
  });

  Map<String, dynamic> tojson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profession': profession,
      'role': role, // Include role in JSON
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      name: jsonUser['name'],
      email: jsonUser['email'],
      profession: jsonUser['profession'],
      role: jsonUser['role'], // Ensure role is assigned
    );
  }
}
