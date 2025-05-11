import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

////////////////////////////////////////////////////////////
class UsersDb {
  String username;
  String emaill; // Consider renaming to 'email' for consistency
  String password;
  String usertype;

  // Constructor
  UsersDb({
    required this.username,
    required this.emaill,
    required this.password,
    required this.usertype,
  });

  // Factory constructor for creating an instance from JSON
  factory UsersDb.fromJson(Map<String, Object?> json) {
    return UsersDb(
      username: json['username'] as String,
      emaill: json['emaill'] as String,
      password: json['password'] as String,
      usertype: json['usertype'] as String,
    );
  }

  UsersDb copywith(
      {String? username, String? emaill, String? password, String? usertype}) {
    return UsersDb(
        username: username ?? this.username,
        emaill: emaill ?? this.emaill,
        password: password ?? this.password,
        usertype: usertype ?? this.usertype);
  }

  // Method for converting an instance to JSON (optional, but useful for Firestore)
  Map<String, Object?> toJson() {
    return {
      'username': username,
      'emaill': emaill,
      'password': password,
      'usertype': usertype,
    };
  }

  Future<void> addUserToFirestore(String uid) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      
      // Check if document already exists
      final docSnapshot = await userRef.get();
      if (docSnapshot.exists) {
        print("User document already exists for UID: $uid");
        return;
      }

      // Set user data in Firestore
      await userRef.set(toJson());
      print("User added to Firestore with UID: $uid");
    } catch (e) {
      print("Error adding user to Firestore: $e");
      if (e is FirebaseException) {
        print("Firebase Error Code: ${e.code}");
        print("Firebase Error Message: ${e.message}");
      }
      rethrow;
    }
  }

  //////////////////////////////////////////////////////////////////////
  // Method to fetch the usertype of a specific user by UID
  static Future<String?> getUserTypeByUid(String uid) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final userType = snapshot.data()?['usertype'] as String?;
        if (userType == null) {
          print("User document exists but usertype is null for UID: $uid");
          print("Document data: ${snapshot.data()}");
        }
        return userType;
      } else {
        print("User document not found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching usertype for UID $uid: $e");
      if (e is FirebaseException) {
        print("Firebase Error Code: ${e.code}");
        print("Firebase Error Message: ${e.message}");
      }
      return null;
    }
  }
}
