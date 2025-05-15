import 'package:cloud_firestore/cloud_firestore.dart';

class PatientsDb {
  // Basic Information
  String name;
  int age;
  String sex;
  String email;
  String bloodgroup;
  String uid;
  
  // Contact Information
  String phonenumber;
  String address;
  String emergencyContact;
  
  // Personal Information
  String maritalStatus;
  String occupation;
  String preferredLanguage;
  
  // Physical Information
  double height; // in cm
  double weight; // in kg
  double bmi; // calculated from height and weight
  
  // Medical Information
  String smokingStatus;
  List<String> dietaryRestrictions;
  List<String> allergies;
  String bio;

  PatientsDb({
    required this.name,
    required this.age,
    required this.sex,
    required this.email,
    required this.bloodgroup,
    required this.uid,
    required this.phonenumber,
    required this.address,
    required this.emergencyContact,
    required this.maritalStatus,
    required this.occupation,
    required this.preferredLanguage,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.smokingStatus,
    required this.dietaryRestrictions,
    required this.allergies,
    required this.bio,
  });

  factory PatientsDb.fromJson(Map<String, Object?> json) {
    return PatientsDb(
      name: json['name'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      email: json['email'] as String,
      bloodgroup: json['bloodgroup'] as String,
      uid: json['uid'] as String,
      phonenumber: json['phonenumber'] as String,
      address: json['address'] as String,
      emergencyContact: json['emergencyContact'] as String,
      maritalStatus: json['maritalStatus'] as String,
      occupation: json['occupation'] as String,
      preferredLanguage: json['preferredLanguage'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      smokingStatus: json['smokingStatus'] as String,
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>).cast<String>(),
      allergies: (json['allergies'] as List<dynamic>).cast<String>(),
      bio: json['bio'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'email': email,
      'bloodgroup': bloodgroup,
      'uid': uid,
      'phonenumber': phonenumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'maritalStatus': maritalStatus,
      'occupation': occupation,
      'preferredLanguage': preferredLanguage,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'smokingStatus': smokingStatus,
      'dietaryRestrictions': dietaryRestrictions,
      'allergies': allergies,
      'bio': bio,
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
