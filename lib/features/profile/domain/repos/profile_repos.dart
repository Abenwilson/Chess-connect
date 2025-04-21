import 'package:photographers/features/profile/domain/entities/profile_user.dart';
/*

profile Repos

*/

abstract class ProfileRepos {
  Future<ProfileUser?> fetchUserProfile(String uid);
  Future<List<ProfileUser>> fetchAllUsers(); // Add this
  Future<void> updateprofile(ProfileUser updatedprofile);
  Future<void> toggleFollow(String currentUid, String targetUid);
}
