import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:safe_space_app/pages/bookappointment.dart';
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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          toolbarHeight: isDesktop ? 80 : 70,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PatientsDb>(
      future: fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              toolbarHeight: isDesktop ? 80 : 70,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Error',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              toolbarHeight: isDesktop ? 80 : 70,
            ),
            body: Center(
              child: Text(
                'Error fetching profile: ${snapshot.error}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isDesktop ? 20 : 18,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final patient = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              centerTitle: true,
              toolbarHeight: isDesktop ? 80 : 70,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    size: isDesktop ? 32 : 24,
                  ),
                  onPressed: () {
                    // Show help dialog or FAQs
                  },
                ),
              ],
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 1000 : (isTablet ? 800 : screenSize.width),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : (isTablet ? 20 : 16),
                    vertical: isDesktop ? 40 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPatientDetailsCard(patient, isDesktop),
                      SizedBox(height: isDesktop ? 32 : 20),
                      _buildAppointmentDetailsCard(isDesktop),
                      SizedBox(height: isDesktop ? 32 : 20),
                      _buildTimeSlotCard(isDesktop),
                      SizedBox(height: isDesktop ? 32 : 20),
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
                                    content: Text('Error fetching doctor details: $e'),
                                  ),
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
                              
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please fill in all fields')),
                              );
                            }
                          },
                          icon: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: isDesktop ? 32 : 24,
                          ),
                          label: Text(
                            'Book Appointment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop ? 20 : 18,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 40 : 32,
                              vertical: isDesktop ? 20 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Error',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              toolbarHeight: isDesktop ? 80 : 70,
            ),
            body: Center(child: Text('Unexpected error occurred')),
          );
        }
      },
    );
  }

  Widget _buildPatientDetailsCard(PatientsDb patient, bool isDesktop) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Patient Details',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 10),
              Text(
                'Name: ${patient.username}',
                style: TextStyle(fontSize: isDesktop ? 18 : 16),
              ),
              Text(
                'Email: ${patient.email}',
                style: TextStyle(fontSize: isDesktop ? 18 : 16),
              ),
              Text(
                'Age: ${patient.age}',
                style: TextStyle(fontSize: isDesktop ? 18 : 16),
              ),
              Text(
                'Gender: ${patient.sex}',
                style: TextStyle(fontSize: isDesktop ? 18 : 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(bool isDesktop) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appointment Details',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 10),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchDoctors(),
                builder: (context, doctorSnapshot) {
                  if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (doctorSnapshot.hasError) {
                    return Text('Error fetching doctors');
                  } else if (doctorSnapshot.hasData) {
                    final doctorList = doctorSnapshot.data!;
                    return DropdownButton<String>(
                      hint: Text(
                        'Select Doctor',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                        ),
                      ),
                      value: selectedDoctorUid,
                      isExpanded: true,
                      icon: Icon(
                        Icons.person,
                        color: Color(0xFF1976D2),
                        size: isDesktop ? 32 : 24,
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          selectedDoctorUid = newValue;
                        });
                      },
                      items: doctorList.map((doctor) {
                        return DropdownMenuItem<String>(
                          value: doctor['uid'],
                          child: Text(
                            doctor['username'],
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Text('No doctors available');
                  }
                },
              ),
              SizedBox(height: isDesktop ? 24 : 20),
              TextField(
                controller: _reasonForVisitController,
                decoration: InputDecoration(
                  labelText: 'Reason for Visit',
                  labelStyle: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 20),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : 20),
              buildDropdown<String>(
                hint: 'Select Appointment Type',
                value: appointmentType,
                items: appointmentTypes,
                onChanged: (newValue) {
                  setState(() {
                    appointmentType = newValue;
                  });
                },
                isDesktop: isDesktop,
              ),
              SizedBox(height: isDesktop ? 24 : 20),
              buildDropdown<String>(
                hint: 'Select Urgency Level',
                value: urgencyLevel,
                items: urgencyLevels,
                onChanged: (newValue) {
                  setState(() {
                    urgencyLevel = newValue;
                  });
                },
                isDesktop: isDesktop,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(bool isDesktop) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Slots',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Slot:',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 10),
                    Text(
                      selectedDateAndTime,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (selectedDoctorUid != null) {
                            final result = await navigateToDoctorSlots(selectedDoctorUid!);

                            if (result != null) {
                              setState(() {
                                selectedDateAndTime = '${result['day']} at ${result['time']}';
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a doctor first.'),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          Icons.calendar_today,
                          size: isDesktop ? 24 : 20,
                        ),
                        label: Text(
                          'Select Time Slot',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 24,
                            vertical: isDesktop ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required bool isDesktop,
  }) {
    return DropdownButton<T>(
      hint: Text(
        hint,
        style: TextStyle(
          fontSize: isDesktop ? 18 : 16,
        ),
      ),
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
            ),
          ),
        );
      }).toList(),
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
