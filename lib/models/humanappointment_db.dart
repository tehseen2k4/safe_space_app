import 'package:cloud_firestore/cloud_firestore.dart';

class HumanAppointmentDb {
  String appointmentId;
  String doctorUid;
  String patientUid;
  String username;
  String email;
  String gender;
  String phonenumber;
  String reasonforvisit;
  String typeofappointment;
  String doctorpreference;
  String urgencylevel;
  String uid;
  String age;
  String timeslot;
  bool? status;
  String? doctorResponse;
  String? responseStatus;
  DateTime? responseTimestamp;
  String? doctorNotes;
  String? suggestedTimeslot;

  HumanAppointmentDb({
    required this.appointmentId,
    required this.doctorUid,
    required this.patientUid,
    required this.username,
    required this.email,
    required this.gender,
    required this.phonenumber,
    required this.reasonforvisit,
    required this.typeofappointment,
    required this.doctorpreference,
    required this.urgencylevel,
    required this.uid,
    required this.timeslot,
    required this.age,
    required this.status,
    this.doctorResponse,
    this.responseStatus,
    this.responseTimestamp,
    this.doctorNotes,
    this.suggestedTimeslot,
  });

  factory HumanAppointmentDb.fromJson(Map<String, Object?> json) {
    return HumanAppointmentDb(
        appointmentId: json['appointmentId'] as String,
        doctorUid: json['doctorUid'] as String,
        patientUid: json['patientUid'] as String,
        username: json['username'] as String,
        email: json['email'] as String,
        gender: json['gender'] as String,
        phonenumber: json['phonenumber'] as String,
        reasonforvisit: json['reasonforvisit'] as String,
        typeofappointment: json['typeofappointment'] as String,
        doctorpreference: json['doctorpreference'] as String,
        urgencylevel: json['urgencylevel'] as String,
        uid: json['uid'] as String,
        age: json['age'] as String,
        timeslot: (json['timeslot'] as String),
        status: json['status'] == null ? false : json['status'] as bool,
        doctorResponse: json['doctorResponse'] as String? ?? '',
        responseStatus: json['responseStatus'] as String? ?? 'pending',
        responseTimestamp: json['responseTimestamp'] != null 
            ? (json['responseTimestamp'] as Timestamp).toDate()
            : null,
        doctorNotes: json['doctorNotes'] as String? ?? '',
        suggestedTimeslot: json['suggestedTimeslot'] as String? ?? '');
  }

  Map<String, Object?> toJson() {
    return {
      'appointmentId': appointmentId,
      'doctorUid': doctorUid,
      'patientUid': patientUid,
      'username': username,
      'email': email,
      'gender': gender,
      'phonenumber': phonenumber,
      'reasonforvisit': reasonforvisit,
      'typeofappointment': typeofappointment,
      'doctorpreference': doctorpreference,
      'urgencylevel': urgencylevel,
      'uid': uid,
      'age': age,
      'timeslot': timeslot,
      'status': status,
      'doctorResponse': doctorResponse,
      'responseStatus': responseStatus,
      'responseTimestamp': responseTimestamp != null 
          ? Timestamp.fromDate(responseTimestamp!)
          : null,
      'doctorNotes': doctorNotes,
      'suggestedTimeslot': suggestedTimeslot,
    };
  }

  /// Function to save the appointment to Firestore
  Future<void> saveToFirestore() async {
    final collection =
        FirebaseFirestore.instance.collection('humanappointments');

    try {
      await collection.doc(appointmentId).set(toJson());
      print("Appointment saved successfully to Firestore.");
    } catch (e) {
      print("Failed to save appointment: $e");
    }
  }
}
