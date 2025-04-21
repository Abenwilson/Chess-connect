// auth state managment
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/features/auth/domain/repos/auth_repos.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  final AuthRepos authRepos;
  AppUser? _currentUser;
  AuthCubit({required this.authRepos}) : super(AuthIntial());

// check user is already aiuthenticated
  void checkAuth() async {
    final AppUser? user = await authRepos.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(unauthenticated());
    }
  }

  AppUser? get currentUser => _currentUser;
  //login with email

  Future<void> login(String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepos.loginWithEmailPassword(email, pw);
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(unauthenticated());
    }
  }

  //register
  Future<void> register(
    String name,
    String email,
    String pw,
    String pro,
  ) async {
    try {
      emit(AuthLoading());
      final user = await authRepos.registerWithEmailPassword(
        name,
        email,
        pw,
        pro,
      );
      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(unauthenticated());
    }
  }

  //logout
  Future<void> logout() async {
    authRepos.logout();
    emit(unauthenticated());
  }
}
