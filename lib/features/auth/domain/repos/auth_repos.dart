/*
auth repositorty -Guidlines the possible auth operation for this app 
*/
import 'package:photographers/features/auth/domain/entities/app_user.dart';

abstract class AuthRepos {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password, String profession);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
