import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorsDb {
  final String name;
  final String username;
  final String specialization;
  final String qualification;
  final String bio;
  final String email;
  final int age;
  final String sex;
  final String uid;
  final String licenseNumber;
  final List<String>? availableDays;
  final String? startTime;
  final String? endTime;
  final String phonenumber;
  final String clinicName;
  final String contactNumberClinic;
  final double fees;
  final String doctorType;
  final String experience;
  final String? language;
  final bool? autoConfirmAppointments;
  final int? sessionDuration;
  final bool? smsNotifications;
  final bool? emailNotifications;
  final bool? darkMode;
  final bool? showAvailability;

  DoctorsDb({
    required this.name,
    required this.username,
    required this.specialization,
    required this.qualification,
    required this.bio,
    required this.email,
    required this.age,
    required this.sex,
    required this.uid,
    required this.licenseNumber,
    this.availableDays,
    this.startTime,
    this.endTime,
    required this.phonenumber,
    required this.clinicName,
    required this.contactNumberClinic,
    required this.fees,
    required this.doctorType,
    required this.experience,
    this.language,
    this.autoConfirmAppointments,
    this.sessionDuration,
    this.smsNotifications,
    this.emailNotifications,
    this.darkMode,
    this.showAvailability,
  });

  factory DoctorsDb.fromJson(Map<String, dynamic> json) {
    return DoctorsDb(
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      email: json['email'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      sex: json['sex'] as String? ?? '',
      uid: json['uid'] as String? ?? '',
      licenseNumber: json['licenseNumber'] as String? ?? '',
      availableDays: (json['availableDays'] as List<dynamic>?)?.cast<String>(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      phonenumber: json['phonenumber'] as String? ?? '',
      clinicName: json['clinicName'] as String? ?? '',
      contactNumberClinic: json['contactNumberClinic'] as String? ?? '',
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      doctorType: json['doctorType'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      language: json['language'] as String?,
      autoConfirmAppointments: json['autoConfirmAppointments'] as bool?,
      sessionDuration: json['sessionDuration'] as int?,
      smsNotifications: json['smsNotifications'] as bool?,
      emailNotifications: json['emailNotifications'] as bool?,
      darkMode: json['darkMode'] as bool?,
      showAvailability: json['showAvailability'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'specialization': specialization,
      'qualification': qualification,
      'bio': bio,
      'email': email,
      'age': age,
      'sex': sex,
      'uid': uid,
      'licenseNumber': licenseNumber,
      'availableDays': availableDays,
      'startTime': startTime,
      'endTime': endTime,
      'phonenumber': phonenumber,
      'clinicName': clinicName,
      'contactNumberClinic': contactNumberClinic,
      'fees': fees,
      'doctorType': doctorType,
      'experience': experience,
      'language': language,
      'autoConfirmAppointments': autoConfirmAppointments,
      'sessionDuration': sessionDuration,
      'smsNotifications': smsNotifications,
      'emailNotifications': emailNotifications,
      'darkMode': darkMode,
      'showAvailability': showAvailability,
    };
  }

  Future<void> checkAndSaveProfile() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('doctors').doc(uid);
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
    }
  }

  DoctorsDb copyWith({
    String? name,
    String? username,
    String? specialization,
    String? qualification,
    String? bio,
    String? email,
    int? age,
    String? sex,
    String? uid,
    String? licenseNumber,
    List<String>? availableDays,
    String? startTime,
    String? endTime,
    String? phonenumber,
    String? clinicName,
    String? contactNumberClinic,
    double? fees,
    String? doctorType,
    String? experience,
    String? language,
    bool? autoConfirmAppointments,
    int? sessionDuration,
    bool? smsNotifications,
    bool? emailNotifications,
    bool? darkMode,
    bool? showAvailability,
  }) {
    return DoctorsDb(
      name: name ?? this.name,
      username: username ?? this.username,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      uid: uid ?? this.uid,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      availableDays: availableDays ?? this.availableDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      phonenumber: phonenumber ?? this.phonenumber,
      clinicName: clinicName ?? this.clinicName,
      contactNumberClinic: contactNumberClinic ?? this.contactNumberClinic,
      fees: fees ?? this.fees,
      doctorType: doctorType ?? this.doctorType,
      experience: experience ?? this.experience,
      language: language ?? this.language,
      autoConfirmAppointments: autoConfirmAppointments ?? this.autoConfirmAppointments,
      sessionDuration: sessionDuration ?? this.sessionDuration,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      darkMode: darkMode ?? this.darkMode,
      showAvailability: showAvailability ?? this.showAvailability,
    );
  }
}
