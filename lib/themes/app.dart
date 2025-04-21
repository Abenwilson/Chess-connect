import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photographers/admin/pages/admin_dashboard.dart';
import 'package:photographers/features/auth/data/firebase_auth_repo.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:photographers/features/auth/presentation/cubits/auth_states.dart';
import 'package:photographers/features/auth/presentation/pages/auth_page.dart';
import 'package:photographers/features/home/presentation/pages/home_page.dart';
import 'package:photographers/features/post/data/firebase_post_repo.dart';
import 'package:photographers/features/post/presentation/cubits/post_cubits.dart';
import 'package:photographers/features/profile/data/firebase_profile_repos.dart';
import 'package:photographers/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:photographers/features/search/data/firebase_searchRepo.dart';
import 'package:photographers/features/search/presentation/cubits/serach_cubits.dart';
import 'package:photographers/features/storage/data/firebase_storage_repo.dart';
import 'package:photographers/themes/light_mode.dart';

/*
-firebase
*/

/*
Bloc provider for state management
 -post
 -profile
 -search
 -theme

*/

class MyApp extends StatelessWidget {
  final firebaseauthRepo = FirebaseAuthRepo();
  //profile Repos
  final firebaseprofileRepo = FirebaseProfileRepos();
  //storage Repo
  final firebasestorageRepo = FirebaseStorageRepo();
  //post Repos
  final firebasePostRepo = FirebasePostRepo();

  //searchRepos
  final firebaseSearchrepo = FirebaseSearchrepo();

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          //auth cubit
          BlocProvider<AuthCubit>(
              create: (context) =>
                  AuthCubit(authRepos: firebaseauthRepo)..checkAuth()),

          //profile cubit
          BlocProvider<ProfileCubits>(
              create: (context) => ProfileCubits(
                  storageRepo: firebasestorageRepo,
                  profileRepos: firebaseprofileRepo)),
          //post cubits
          BlocProvider<PostCubits>(
            create: (context) => PostCubits(
                postRepos: firebasePostRepo, storageRepo: firebasestorageRepo),
          ),
          //Search cubit

          BlocProvider<SerachCubits>(
              create: (context) =>
                  SerachCubits(searchRepo: firebaseSearchrepo)),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightMode,
            home: BlocConsumer<AuthCubit, AuthStates>(
                builder: (context, authStates) {
              print(authStates);
              // unauthenticated -> login
              if (authStates is unauthenticated) {
                return const AuthPage();
              }
              // authenticated -> homepage
              if (authStates is Authenticated) {
                if (authStates.user.role == "admin") {
                  return AdminDashboard(); // Navigate to Admin Page
                } else {
                  return HomePage(); // Navigate to User Home
                }
              }
              //loading..

              else {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            }, listener: (context, State) {
              if (State is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(State.message),
                ));
              }
            })));
  }
}
