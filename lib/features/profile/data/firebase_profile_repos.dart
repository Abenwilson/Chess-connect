// profile repositories
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photographers/features/profile/domain/repos/profile_repos.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';

class FirebaseProfileRepos implements ProfileRepos {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      final userDoc = await firebaseFirestore
          .collection('users') //  FIXED: Collection name should be 'users'
          .doc(uid)
          .get(); //  FIXED: Fetch fresh data

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          // fetch the followers
          final followers = List<String>.from(userData['followers'] ?? []);
          final following = List<String>.from(userData['following'] ?? []);

          return ProfileUser(
            uid: uid,
            name: userData['name'],
            email: userData['email'],
            bio: userData['bio'] ?? '',
            role: userData['role'] ?? 'user', // Ensure role is included
            profession: userData['profession'],
            profileImagUrl: userData['profileImagUrl'] ?? '',
            followers: followers,
            following: following,
          );
        }
      }
      return null;
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  @override
  Future<List<ProfileUser>> fetchAllUsers() async {
    try {
      final querySnapshot = await firebaseFirestore.collection('users').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProfileUser(
          uid: doc.id,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: data['role'] ?? 'user', // Ensure role is included
          bio: data['bio'] ?? '',
          profession: data['profession'] ?? '',
          profileImagUrl: data['profileImagUrl'] ?? '',
          followers: List<String>.from(data['followers'] ?? []),
          following: List<String>.from(data['following'] ?? []),
        );
      }).toList();
    } catch (e) {
      print("Error fetching all users: $e");
      throw Exception("Error fetching users");
    }
  }

  @override
  Future<void> updateprofile(ProfileUser updatedprofile) async {
    try {
      await firebaseFirestore
          .collection('users')
          .doc(updatedprofile.uid)
          .update({
        if (updatedprofile.profession.isNotEmpty)
          'profession':
              updatedprofile.profession, // ✅ Fix: Only update if not empty
        'bio': updatedprofile.bio, // ✅ FIXED: Removed extra space
        'profileImagUrl': updatedprofile.profileImagUrl,
      });
    } catch (e) {
      throw Exception("Error updating profile: $e");
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserRef =
          firebaseFirestore.collection('users').doc(currentUid);

      final targetUserRef =
          firebaseFirestore.collection('users').doc(targetUid);

      final currentUserDoc = await currentUserRef.get();
      final targetUserDoc = await targetUserRef.get();
      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();
        if (currentUserData != null && targetUserData != null) {
          final List<String> currentFollowing =
              List<String>.from(currentUserData['following'] ?? []);

          //check if the current user is already following the target user

          if (currentFollowing.contains(targetUid)) {
            // Unfollow
            await currentUserRef.update({
              'following': FieldValue.arrayRemove([targetUid])
            });
            await targetUserRef.update({
              'followers': FieldValue.arrayRemove([currentUid])
            });
          } else {
            // Follow
            await currentUserRef.update({
              'following': FieldValue.arrayUnion([targetUid])
            });
            await targetUserRef.update({
              'followers': FieldValue.arrayUnion([currentUid])
            });
          }
        }
      }
    } catch (e) {
      print("Error toggling follow state: $e");
      throw Exception("Error toggling follow state");
    }
  }
}
