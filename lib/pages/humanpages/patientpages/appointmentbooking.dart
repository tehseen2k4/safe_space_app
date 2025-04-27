
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:safe_space_app/models/bookappointment.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';

class BookAppointmentPage extends StatefulWidget {
  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _reasonForVisitController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? selectedDoctorUid;
  String? appointmentType;
  String? urgencyLevel;
  String selectedDateAndTime = "None";

  final List<String> appointmentTypes = ['General', 'Specialist', 'Emergency'];
  final List<String> urgencyLevels = ['Normal', 'Urgent', 'Critical'];

  @override
  void dispose() {
    _reasonForVisitController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Human')
          .get();
      return snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'username': doc['username'],
              })
          .toList();
    } catch (e) {
      print("Error fetching doctors: $e");
      return [];
    }
  }

  Future<PatientsDb> fetchProfile(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('humanpatients')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PatientsDb.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        throw Exception('Profile not found.');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  Widget buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButton<T>(
      hint: Text(hint),
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Book Appointment')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PatientsDb>(
      future: fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Book Appointment')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(
              child: Text(
                'Error fetching profile: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final patient = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text('Book Appointment'),
              backgroundColor: const Color.fromARGB(255, 2, 93, 98),
              foregroundColor: Colors.white,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.help_outline),
                  onPressed: () {
                    // Show help dialog or FAQs
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Details
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patient Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text('Name: ${patient.username}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Email: ${patient.email}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Age: ${patient.age}',
                                  style: TextStyle(fontSize: 16)),
                              Text('Gender: ${patient.sex}',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Appointment Details
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 10),
                              FutureBuilder<List<Map<String, dynamic>>>(
                                future: fetchDoctors(),
                                builder: (context, doctorSnapshot) {
                                  if (doctorSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (doctorSnapshot.hasError) {
                                    return Text('Error fetching doctors');
                                  } else if (doctorSnapshot.hasData) {
                                    final doctorList = doctorSnapshot.data!;
                                    return DropdownButton<String>(
                                      hint: Text('Select Doctor'),
                                      value: selectedDoctorUid,
                                      isExpanded: true,
                                      icon: Icon(Icons.person,
                                          color:
                                              Color.fromARGB(255, 2, 93, 98)),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedDoctorUid = newValue;
                                        });
                                      },
                                      items: doctorList.map((doctor) {
                                        return DropdownMenuItem<String>(
                                          value: doctor['uid'],
                                          child: Text(doctor['username']),
                                        );
                                      }).toList(),
                                    );
                                  } else {
                                    return Text('No doctors available');
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _reasonForVisitController,
                                decoration: InputDecoration(
                                  labelText: 'Reason for Visit',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _phoneNumberController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              SizedBox(height: 20),
                              buildDropdown<String>(
                                hint: 'Select Appointment Type',
                                value: appointmentType,
                                items: appointmentTypes,
                                onChanged: (newValue) {
                                  setState(() {
                                    appointmentType = newValue;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              buildDropdown<String>(
                                hint: 'Select Urgency Level',
                                value: urgencyLevel,
                                items: urgencyLevels,
                                onChanged: (newValue) {
                                  setState(() {
                                    urgencyLevel = newValue;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Time Slot and Actions
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: Container(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Slots',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Slot:',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      selectedDateAndTime,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (selectedDoctorUid != null) {
                                            final result =
                                                await navigateToDoctorSlots(
                                                    selectedDoctorUid!);

                                            if (result != null) {
                                              setState(() {
                                                selectedDateAndTime =
                                                    '${result['day']} at ${result['time']}';
                                              });
                                            }
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Please select a doctor first.'),
                                              ),
                                            );
                                          }
                                        },
                                        icon: Icon(Icons.calendar_today),
                                        label: Text('Select Time Slot'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (selectedDoctorUid != null &&
                              appointmentType != null &&
                              urgencyLevel != null &&
                              _reasonForVisitController.text.isNotEmpty &&
                              _phoneNumberController.text.isNotEmpty) {
                            String? doctorName;
                            try {
                              final doctorDoc = await _firestore
                                  .collection('doctors')
                                  .doc(selectedDoctorUid)
                                  .get();
                              if (doctorDoc.exists) {
                                doctorName = doctorDoc['username'];
                              } else {
                                throw Exception('Doctor not found');
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error fetching doctor details: $e')),
                              );
                              return;
                            }

                            final appointmentData = HumanAppointmentDb(
                              username: patient.username,
                              age: patient.age.toString(),
                              gender: patient.sex,
                              email: patient.email,
                              patientUid: user.uid,
                              doctorUid: selectedDoctorUid!,
                              reasonforvisit: _reasonForVisitController.text,
                              typeofappointment: appointmentType!,
                              urgencylevel: urgencyLevel!,
                              phonenumber: _phoneNumberController.text,
                              timeslot: selectedDateAndTime,
                              uid: user.uid,
                              appointmentId: generateAppointmentId(),
                              doctorpreference: doctorName!,
                              status: false,
                            );

                            await _firestore
                                .collection('appointments')
                                .add(appointmentData.toJson());

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Appointment Booked!')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Please fill in all fields')),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Book Appointment',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 2, 93, 98),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Unexpected error occurred')),
          );
        }
      },
    );
  }

  Future<Map<String, dynamic>?> navigateToDoctorSlots(String doctorId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorSlotsWidget(doctorId: doctorId),
      ),
    );

    if (result != null) {
      return result;
    }
    return null;
  }

  String generateAppointmentId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(1000000); // Random 6-digit number
    return '$timestamp-$randomSuffix'; // Combining timestamp and random number
  }
}
