// manage states

import 'package:photographers/features/auth/domain/entities/app_user.dart';

abstract class AuthStates {}

//initial

class AuthIntial extends AuthStates {}

//loading ..
class AuthLoading extends AuthStates {}

//authentication

class Authenticated extends AuthStates {
  final AppUser user;
  Authenticated(this.user);
}

//unauthentication

class unauthenticated extends AuthStates {}

//authError
class AuthError extends AuthStates {
  final String message;
  AuthError(this.message);
}
