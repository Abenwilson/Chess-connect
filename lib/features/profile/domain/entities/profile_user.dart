import 'package:photographers/features/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImagUrl;
  final List<String> followers;
  final List<String> following;

  ProfileUser({
    required super.uid,
    required super.name,
    required super.email,
    required super.role, // Include role here

    required this.bio,
    required super.profession,
    required this.profileImagUrl,
    required this.followers,
    required this.following,
  });

  // method to update user profile
  ProfileUser copywith(
      {String? newBio,
      String? newProfession,
      String? newPofileImageUrl,
      List<String>? newfollowers,
      List<String>? newfollowing}) {
    return ProfileUser(
      uid: uid,
      name: name,
      email: email,
      role: role, // Ensure role is copied
      bio: newBio ?? bio,
      profession: newProfession ?? profession,
      profileImagUrl: newPofileImageUrl ?? profileImagUrl,
      followers: newfollowers ?? followers,
      following: newfollowing ?? following,
    );
  }

  @override
  Map<String, dynamic> tojson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role, // Ensure role is included
      'bio': bio,
      'profession': profession,
      'profileImagUrl': profileImagUrl,
      'followers': followers,
      'following': following,
    };
  }

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? 'user', // Ensure default role if missing
      bio: json['bio'] ?? '',
      profession: json['profession'],
      profileImagUrl: json['profileImagUrl'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }
}
