import 'package:cloud_firestore/cloud_firestore.dart';

class PetPatientDB {
  static final _firestore = FirebaseFirestore.instance;
  static const _collection = 'pet_patients';

  static Future<Map<String, dynamic>?> getPetPatientProfile(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting pet patient profile: $e');
      return null;
    }
  }

  static Future<void> updatePetPatientProfile(
    String userId, {
    String? name,
    String? species,
    String? breed,
    int? age,
    double? weight,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (species != null) data['species'] = species;
      if (breed != null) data['breed'] = breed;
      if (age != null) data['age'] = age;
      if (weight != null) data['weight'] = weight;

      await _firestore.collection(_collection).doc(userId).set(
        data,
        SetOptions(merge: true),
      );
    } catch (e) {
      print('Error updating pet patient profile: $e');
      rethrow;
    }
  }
} 