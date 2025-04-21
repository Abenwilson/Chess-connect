// profile states

import 'package:photographers/features/profile/domain/entities/profile_user.dart';

abstract class ProfileStates {}

//initial
class ProfileInitial extends ProfileStates {}

//loading

class ProfileLoading extends ProfileStates {}

//loaded
class ProfileLoaded extends ProfileStates {
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
}

//error
class AllUsersLoaded extends ProfileStates {
  final List<ProfileUser> users;
  AllUsersLoaded(this.users);
}

class ProfileError extends ProfileStates {
  final String message;
  ProfileError(this.message);
}
