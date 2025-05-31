import 'package:cloud_firestore/cloud_firestore.dart';

class HumanAppointmentDb {
  final String appointmentId;
  final String uid;
  final String patientUid;
  final String doctorUid;
  final String username;
  final String age;
  final String gender;
  final String email;
  final String reasonforvisit;
  final String typeofappointment;
  final String urgencylevel;
  final String phonenumber;
  final String timeslot;
  final String doctorpreference;
  final bool status;
  final String? responseStatus;
  final String? suggestedTimeslot;
  final String slotId;
  Timestamp? responseTimestamp;
  String? doctorResponse;
  String? doctorNotes;
  String? documentId;

  HumanAppointmentDb({
    required this.appointmentId,
    required this.uid,
    required this.patientUid,
    required this.doctorUid,
    required this.username,
    required this.age,
    required this.gender,
    required this.email,
    required this.reasonforvisit,
    required this.typeofappointment,
    required this.urgencylevel,
    required this.phonenumber,
    required this.timeslot,
    required this.doctorpreference,
    required this.status,
    this.responseStatus,
    this.suggestedTimeslot,
    required this.slotId,
    this.responseTimestamp,
    this.doctorResponse,
    this.doctorNotes,
    this.documentId,
  });

  factory HumanAppointmentDb.fromJson(Map<String, dynamic> json) {
    return HumanAppointmentDb(
      appointmentId: json['appointmentId'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      patientUid: json['patientUid'] as String? ?? '',
      doctorUid: json['doctorUid'] as String? ?? '',
      username: json['username'] as String? ?? '',
      age: json['age'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      email: json['email'] as String? ?? '',
      reasonforvisit: json['reasonforvisit'] as String? ?? '',
      typeofappointment: json['typeofappointment'] as String? ?? '',
      urgencylevel: json['urgencylevel'] as String? ?? '',
      phonenumber: json['phonenumber'] as String? ?? '',
      timeslot: json['timeslot'] as String? ?? '',
      doctorpreference: json['doctorpreference'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      responseStatus: json['responseStatus'] as String?,
      suggestedTimeslot: json['suggestedTimeslot'] as String?,
      slotId: json['slotId'] as String? ?? '',
      responseTimestamp: json['responseTimestamp'] as Timestamp?,
      doctorResponse: json['doctorResponse'] as String?,
      doctorNotes: json['doctorNotes'] as String?,
      documentId: json['documentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'uid': uid,
      'patientUid': patientUid,
      'doctorUid': doctorUid,
      'username': username,
      'age': age,
      'gender': gender,
      'email': email,
      'reasonforvisit': reasonforvisit,
      'typeofappointment': typeofappointment,
      'urgencylevel': urgencylevel,
      'phonenumber': phonenumber,
      'timeslot': timeslot,
      'doctorpreference': doctorpreference,
      'status': status,
      'responseStatus': responseStatus,
      'responseTimestamp': responseTimestamp,
      'doctorResponse': doctorResponse,
      'doctorNotes': doctorNotes,
      'suggestedTimeslot': suggestedTimeslot,
      'slotId': slotId,
      'documentId': documentId,
    };
  }

  /// Function to save the appointment to Firestore
  Future<void> saveToFirestore() async {
    final collection =
        FirebaseFirestore.instance.collection('appointments');

    try {
      await collection.doc(appointmentId).set(toJson());
      print("Appointment saved successfully to Firestore.");
    } catch (e) {
      print("Failed to save appointment: $e");
    }
  }

  /// Function to update appointment response
  Future<void> updateAppointmentResponse({
    required String response,
    required String status,
    String? notes,
    String? suggestedTime,
  }) async {
    try {
      final collection = FirebaseFirestore.instance.collection('appointments');
      final docRef = collection.doc(appointmentId);
      
      await docRef.update({
        'doctorResponse': response,
        'responseStatus': status,
        'responseTimestamp': FieldValue.serverTimestamp(),
        if (notes != null) 'doctorNotes': notes,
        if (suggestedTime != null) 'suggestedTimeslot': suggestedTime,
      });
      
      print("Appointment response updated successfully");
    } catch (e) {
      print("Failed to update appointment response: $e");
      throw e;
    }
  }
}
