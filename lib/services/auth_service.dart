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
      log("Login error: $e");
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            log('No user found for that email.');
            break;
          case 'wrong-password':
            log('Wrong password provided.');
            break;
          case 'invalid-email':
            log('The email address is not valid.');
            break;
          case 'user-disabled':
            log('This user has been disabled.');
            break;
          default:
            log('Unknown error: ${e.code}');
        }
      }
      rethrow; // Rethrow to handle in the UI
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error during signout: $e");
      rethrow;
    }
  }
}
