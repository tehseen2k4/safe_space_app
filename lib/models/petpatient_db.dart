import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PetpatientDb {
  String name;
  String username;
  int age;
  String sex;
  String email;
  String uid;

  PetpatientDb({
    required this.name,
    required this.username,
    required this.age,
    required this.sex,
    required this.email,
    required this.uid,
  });

  factory PetpatientDb.fromJson(Map<String, Object?> json) {
    return PetpatientDb(
      name: json['name'] as String,
      username: json['username'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
    );
  }

  PetpatientDb copywith(
      {String? name,
      String? username,
      int? age,
      String? sex,
      String? email,
      String? uid}) {
    return PetpatientDb(
        name: name ?? this.name,
        username: username ?? this.username,
        age: age ?? this.age,
        sex: sex ?? this.sex,
        email: email ?? this.email,
        uid: uid ?? this.uid);
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'username': username,
      'age': age,
      'sex': sex,
      'email': email,
      'uid': uid,
    };
  }

  Future<void> checkAndSaveProfile() async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('pets')
          .doc(uid);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.update(toJson());
        print('Profile updated successfully!');
      } else {
        await docRef.set(toJson());
        print('Profile created successfully!');
      }
    } catch (e) {
      print('Error saving/updating profile: $e');
      if (e is FirebaseException) {
        print("Firebase Error Code: ${e.code}");
        print("Firebase Error Message: ${e.message}");
      }
      rethrow;
    }
  }
}
