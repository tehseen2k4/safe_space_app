import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'dart:math';
import '../bookappointment.dart';

class BookAppointmentPetPage extends StatefulWidget {
  @override
  _BookAppointmentPetPageState createState() => _BookAppointmentPetPageState();
}

class _BookAppointmentPetPageState extends State<BookAppointmentPetPage> {
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
          .where('doctorType', isEqualTo: 'Veterinary')
          .get();
      final doctors = snapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'username': doc['username'],
              })
          .toList();
      print('Fetched doctors: $doctors'); // Debugging
      return doctors;
    } catch (e) {
      print("Error fetching doctors: $e");
      return [];
    }
  }

  Future<PetpatientDb> fetchProfile(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('pets')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PetpatientDb.fromJson(
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Book Appointment'),
          backgroundColor: const Color.fromARGB(255, 225, 118, 82),
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PetpatientDb>(
      future: fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Book Appointment'),
              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
              foregroundColor: Colors.white,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
              foregroundColor: Colors.white,
            ),
            body: Center(child: Text('Error fetching profile: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final petpatient = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
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
            body: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildPatientDetailsCard(petpatient, isDesktop),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: _buildAppointmentDetailsCard(isDesktop),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildPatientDetailsCard(petpatient, isDesktop),
                          SizedBox(height: 20),
                          _buildAppointmentDetailsCard(isDesktop),
                        ],
                      ),
                    SizedBox(height: 20),
                    _buildTimeSlotCard(isDesktop),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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

                            final appointmentData = PetAppointmentDb(
                              appointmentId: generateAppointmentId(),
                              doctorUid: selectedDoctorUid!,
                              patientUid: user.uid,
                              username: petpatient.username,
                              email: petpatient.email,
                              petname: petpatient.name,
                              pettype: "Pet",
                              petbreed: "Unknown",
                              petage: petpatient.age.toString(),
                              reasonforvisit: _reasonForVisitController.text,
                              typeofappointment: appointmentType!,
                              doctorpreference: doctorName!,
                              urgencylevel: urgencyLevel!,
                              uid: user.uid,
                              timeslot: selectedDateAndTime,
                              phonenumber: _phoneNumberController.text,
                              status: false,
                            );

                            await _firestore
                                .collection('petappointments')
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 24,
                            vertical: isDesktop ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.white,
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
              title: Text('Error'),
              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
              foregroundColor: Colors.white,
            ),
            body: Center(child: Text('Unexpected error occurred')),
          );
        }
      },
    );
  }

  Widget _buildPatientDetailsCard(PetpatientDb petpatient, bool isDesktop) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
                  color: const Color.fromARGB(255, 225, 118, 82),
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 10),
              _buildDetailRow('Name', petpatient.username, isDesktop),
              _buildDetailRow('Email', petpatient.email, isDesktop),
              _buildDetailRow('Age', petpatient.age.toString(), isDesktop),
              _buildDetailRow('Gender', petpatient.sex, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard(bool isDesktop) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
                  color: const Color.fromARGB(255, 225, 118, 82),
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
                      hint: Text('Select Doctor'),
                      value: selectedDoctorUid,
                      isExpanded: true,
                      icon: Icon(Icons.person,
                          color: const Color.fromARGB(255, 225, 118, 82)),
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
              SizedBox(height: isDesktop ? 20 : 16),
              TextField(
                controller: _reasonForVisitController,
                decoration: InputDecoration(
                  labelText: 'Reason for Visit',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: isDesktop ? 20 : 16),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: isDesktop ? 20 : 16),
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
              SizedBox(height: isDesktop ? 20 : 16),
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
    );
  }

  Widget _buildTimeSlotCard(bool isDesktop) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
                  color: const Color.fromARGB(255, 225, 118, 82),
                ),
              ),
              SizedBox(height: isDesktop ? 16 : 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
                        fontSize: isDesktop ? 20 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 12 : 8),
                    Text(
                      selectedDateAndTime,
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: Colors.blueGrey,
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                              SnackBar(content: Text('Please select a doctor first.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 32 : 24,
                            vertical: isDesktop ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Select Time Slot',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.white,
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
