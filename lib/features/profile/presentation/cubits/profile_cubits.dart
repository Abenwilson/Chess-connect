import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/profile/domain/repos/profile_repos.dart';
import 'package:photographers/features/profile/domain/entities/profile_user.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_states.dart';
import 'package:photographers/features/storage/domain/storage_repo.dart';

class ProfileCubits extends Cubit<ProfileStates> {
  final StorageRepo storageRepo;
  final ProfileRepos profileRepos;

  ProfileCubits({required this.storageRepo, required this.profileRepos})
      : super(ProfileInitial());

  // Fetch user profile
  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepos.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError("User not found"));
      }
    } catch (e) {
      emit(ProfileError("Error in fetchUserProfile: ${e.toString()}"));
    }
  }
  // Add new state to hold a list of users

// Add method to fetch all users
  Future<void> fetchAllUsers() async {
    try {
      emit(ProfileLoading());
      final users = await profileRepos.fetchAllUsers();
      emit(AllUsersLoaded(users));
    } catch (e) {
      emit(ProfileError("Failed to fetch users: $e"));
    }
  }

  //return profile is given uid useful for loading many profile for Post
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepos.fetchUserProfile(uid);
    return user;
  }

  // Update profile
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? newProfession,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());

    try {
      final currentUser = await profileRepos.fetchUserProfile(uid);
      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      // Handle profile picture update
      String? imageDownloadUrl;
      if (imageWebBytes != null || imageMobilePath != null) {
        if (imageMobilePath != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
        } else if (imageWebBytes != null) {
          imageDownloadUrl =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload image"));
          return;
        }
      }

      // Update the profile
      final updatedProfile = currentUser.copywith(
        newBio: newBio ?? currentUser.bio,
        newProfession: newProfession ?? currentUser.profession,
        newPofileImageUrl: imageDownloadUrl ?? currentUser.profileImagUrl,
      );

      await profileRepos.updateprofile(updatedProfile);

      // Emit the updated profile directly
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError("Error in updateProfile: ${e.toString()}"));
    }
  }

  // toggle follow and unfollow
  Future<void> toggleFollow(String currerntUserId, String targetUserId) async {
    try {
      await profileRepos.toggleFollow(currerntUserId, targetUserId);
    } catch (e) {
      emit(ProfileError("error on  toggle follow $e"));
    }
  }
}
