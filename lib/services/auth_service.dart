//import 'dart:math' as math; // Use alias to avoid conflict with 'dart:developer'
import 'dart:developer'; // Import for the log function

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e, stacktrace) {
      log("Error in createUserWithEmailAndPassword: $e",
          stackTrace: stacktrace);
      return null;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      log("Something went wrong: $e"); // Use 'developer.log' explicitly
      return null; // Add return statement to handle nullable return type
    }
  }

  Future<void> signout() async {
    try {} catch (e) {
      await _auth.signOut();
    }
  }
}
