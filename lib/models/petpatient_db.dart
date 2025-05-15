import 'package:cloud_firestore/cloud_firestore.dart';

class PetpatientDb {
  // Basic Information
  String name;
  String type; // Type of pet (e.g., Dog, Cat, Bird)
  String breed;
  int age;
  String sex;
  DateTime dateOfBirth;
  double weight; // in kg
  String neuterStatus; // Neutered/Spayed, Not Neutered/Spayed
  
  // Owner Information
  String ownerName;
  String ownerPhone;
  String emergencyContact;
  String email;
  String uid;

  // Medical Information
  List<String> allergies;
  List<String> specialNeeds;
  DateTime lastVaccination;
  List<String> dietaryRequirements;
  List<String> groomingNeeds;
  String trainingStatus; // e.g., Basic, Intermediate, Advanced, None

  PetpatientDb({
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.sex,
    required this.dateOfBirth,
    required this.weight,
    required this.neuterStatus,
    required this.ownerName,
    required this.ownerPhone,
    required this.emergencyContact,
    required this.email,
    required this.uid,
    required this.allergies,
    required this.specialNeeds,
    required this.lastVaccination,
    required this.dietaryRequirements,
    required this.groomingNeeds,
    required this.trainingStatus,
  });

  factory PetpatientDb.fromJson(Map<String, Object?> json) {
    return PetpatientDb(
      name: json['name'] as String,
      type: json['type'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      dateOfBirth: (json['dateOfBirth'] as Timestamp).toDate(),
      weight: (json['weight'] as num).toDouble(),
      neuterStatus: json['neuterStatus'] as String,
      ownerName: json['ownerName'] as String,
      ownerPhone: json['ownerPhone'] as String,
      emergencyContact: json['emergencyContact'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
      allergies: (json['allergies'] as List<dynamic>).cast<String>(),
      specialNeeds: (json['specialNeeds'] as List<dynamic>).cast<String>(),
      lastVaccination: (json['lastVaccination'] as Timestamp).toDate(),
      dietaryRequirements: (json['dietaryRequirements'] as List<dynamic>).cast<String>(),
      groomingNeeds: (json['groomingNeeds'] as List<dynamic>).cast<String>(),
      trainingStatus: json['trainingStatus'] as String,
    );
  }

  PetpatientDb copywith({
    String? name,
    String? type,
    String? breed,
    int? age,
    String? sex,
    DateTime? dateOfBirth,
    double? weight,
    String? neuterStatus,
    String? ownerName,
    String? ownerPhone,
    String? emergencyContact,
    String? email,
    String? uid,
    List<String>? allergies,
    List<String>? specialNeeds,
    DateTime? lastVaccination,
    List<String>? dietaryRequirements,
    List<String>? groomingNeeds,
    String? trainingStatus,
  }) {
    return PetpatientDb(
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      neuterStatus: neuterStatus ?? this.neuterStatus,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      allergies: allergies ?? this.allergies,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      lastVaccination: lastVaccination ?? this.lastVaccination,
      dietaryRequirements: dietaryRequirements ?? this.dietaryRequirements,
      groomingNeeds: groomingNeeds ?? this.groomingNeeds,
      trainingStatus: trainingStatus ?? this.trainingStatus,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'sex': sex,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'weight': weight,
      'neuterStatus': neuterStatus,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'emergencyContact': emergencyContact,
      'email': email,
      'uid': uid,
      'allergies': allergies,
      'specialNeeds': specialNeeds,
      'lastVaccination': Timestamp.fromDate(lastVaccination),
      'dietaryRequirements': dietaryRequirements,
      'groomingNeeds': groomingNeeds,
      'trainingStatus': trainingStatus,
    };
  }

  Future<void> checkAndSaveProfile() async {
    try {
      // Reference to 'pets' collection
      final docRef = FirebaseFirestore.instance
          .collection('pets')
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
