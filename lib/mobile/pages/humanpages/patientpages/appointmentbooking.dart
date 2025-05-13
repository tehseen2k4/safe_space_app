import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:safe_space_app/mobile/pages/bookappointment.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _reasonForVisitController = TextEditingController();
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

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          centerTitle: true,
          toolbarHeight: 70,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PatientsDb>(
      future: fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              centerTitle: true,
              toolbarHeight: 70,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              centerTitle: true,
              toolbarHeight: 70,
            ),
            body: Center(
              child: Text(
                'Error fetching profile: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final patient = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              centerTitle: true,
              toolbarHeight: 70,
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    // Show help dialog or FAQs
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientDetailsCard(patient),
                    const SizedBox(height: 20),
                    _buildAppointmentDetailsCard(),
                    const SizedBox(height: 20),
                    _buildTimeSlotCard(),
                    const SizedBox(height: 20),
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
                              const SnackBar(content: Text('Appointment Booked!')),
                            );
                            
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill in all fields')),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Book Appointment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
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
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              centerTitle: true,
              toolbarHeight: 70,
            ),
            body: const Center(child: Text('Unexpected error occurred')),
          );
        }
      },
    );
  }

  Widget _buildPatientDetailsCard(PatientsDb patient) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Name: ${patient.username}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Email: ${patient.email}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Age: ${patient.age}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Gender: ${patient.sex}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDoctors(),
              builder: (context, doctorSnapshot) {
                if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (doctorSnapshot.hasError) {
                  return const Text('Error fetching doctors');
                } else if (doctorSnapshot.hasData) {
                  final doctorList = doctorSnapshot.data!;
                  return DropdownButton<String>(
                    hint: const Text(
                      'Select Doctor',
                      style: TextStyle(fontSize: 16),
                    ),
                    value: selectedDoctorUid,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.person,
                      color: Color(0xFF1976D2),
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
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return const Text('No doctors available');
                }
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reasonForVisitController,
              decoration: InputDecoration(
                labelText: 'Reason for Visit',
                labelStyle: const TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
    );
  }

  Widget _buildTimeSlotCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Slots',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Slot:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedDateAndTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                            const SnackBar(
                              content: Text('Please select a doctor first.'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text(
                        'Select Time Slot',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
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
    );
  }

  Widget buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButton<T>(
      hint: Text(
        hint,
        style: const TextStyle(fontSize: 16),
      ),
      value: value,
      onChanged: onChanged,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            item.toString(),
            style: const TextStyle(fontSize: 16),
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
