import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photographers/features/auth/domain/entities/app_user.dart';
import 'package:photographers/features/auth/domain/repos/auth_repos.dart';

class FirebaseAuthRepo implements AuthRepos {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) return null;

      // Construct AppUser with role
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        name: userDoc['name'],
        email: email,
        role: userDoc['role'], // Fetch role
        profession: userDoc['profession'],
      );

      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
    String profession,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //
      AppUser user = AppUser(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          profession: profession,
          role: "user");

      //save user data in firestore

      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.tojson());

      return user;
    } catch (e) {
      throw Exception('login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // person that current logged in
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }
// fetch user document from firestore
    DocumentSnapshot userDoc =
        await firebaseFirestore.collection("users").doc(firebaseUser.uid).get();
    //check user doc exist
    if (!userDoc.exists) {
      return null;
    }

    return AppUser(
      uid: firebaseUser.uid,
      name: userDoc['name'],
      email: firebaseUser.email!,
      role: userDoc['role'], // Fetch and assign role
      profession: '',
    );
  }
}
