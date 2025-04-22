import 'package:cloud_firestore/cloud_firestore.dart';

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
      // Reference to the 'users' collection
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // Set user data in Firestore
      await userRef.set(toJson());

      print("User added to Firestore with UID: $uid");
    } catch (e) {
      print("Error adding user to Firestore: $e");
      rethrow;
    }
  }

  //////////////////////////////////////////////////////////////////////
  // Method to fetch the usertype of a specific user by UID
  static Future<String?> getUserTypeByUid(String uid) async {
    try {
      // Reference to the specific user document
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

      // Fetch the document snapshot
      final snapshot = await userDoc.get();

      // Check if the document exists
      if (snapshot.exists) {
        // Extract the usertype field from the document
        final userType = snapshot.data()?['usertype'] as String?;
        return userType;
      } else {
        print("User with UID $uid not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching usertype for UID $uid: $e");
      return null;
    }
  }
}
