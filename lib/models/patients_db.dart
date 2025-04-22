import 'package:cloud_firestore/cloud_firestore.dart';

class PatientsDb {
  String name;
  String username;
  int age; // Fixed 'Int' to 'int' (Dart uses 'int' for integers)
  String sex;
  String email;
  String bloodgroup;
  String uid;

  PatientsDb({
    required this.name,
    required this.username,
    required this.age,
    required this.sex,
    required this.email,
    required this.bloodgroup,
    required this.uid,
  });

  factory PatientsDb.fromJson(Map<String, Object?> json) {
    return PatientsDb(
      name: json['name'] as String,
      username: json['username'] as String,
      age: json['age'] as int, // Fixed 'Int' to 'int'
      sex: json['sex'] as String,
      email: json['email'] as String,
      bloodgroup: json['bloodgroup'] as String,
      uid: json['uid'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'username': username,
      'age': age,
      'sex': sex,
      'email': email,
      'bloodgroup': bloodgroup,
      'uid': uid,
    };
  }

  /// Check if profile exists and save/update it in Firestore
  Future<void> checkAndSaveProfile() async {
    try {
      // Reference to 'humanpatients' collection
      final docRef = FirebaseFirestore.instance
          .collection('humanpatients')
          .doc(uid); // Use `uid` as the document ID

      // Check if document exists
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // If document exists, update it
        await docRef.update(toJson());
        print('Profile updated successfully!');
      } else {
        // If document does not exist, create it
        await docRef.set(toJson());
        print('Profile created successfully!');
      }
    } catch (e) {
      print('Error saving/updating profile: $e');
    }
  }
}
