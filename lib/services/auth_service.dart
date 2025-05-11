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
      rethrow;
    }
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e, stacktrace) {
      log("Error in loginUserWithEmailAndPassword: $e",
          stackTrace: stacktrace);
      if (e is FirebaseAuthException) {
        log("Firebase Auth Error Code: ${e.code}");
        log("Firebase Auth Error Message: ${e.message}");
      }
      rethrow;
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e, stacktrace) {
      log("Error in signout: $e", stackTrace: stacktrace);
      rethrow;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
