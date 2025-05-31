import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';
import 'dart:math';
import '../bookappointment.dart';

class BookAppointmentPetPage extends StatefulWidget {
  @override
  _BookAppointmentPetPageState createState() => _BookAppointmentPetPageState();
}

class _BookAppointmentPetPageState extends State<BookAppointmentPetPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _reasonForVisitController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? selectedDoctorUid;
  String? appointmentType;
  String? urgencyLevel;
  String selectedDateAndTime = "None";

  final List<String> appointmentTypes = ['General', 'Specialist', 'Emergency'];
  final List<String> urgencyLevels = ['Normal', 'Urgent', 'Critical'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _reasonForVisitController.dispose();
    _phoneNumberController.dispose();
    _animationController.dispose();
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
      return doctors;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching doctors: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE17652)),
      ),
      child: DropdownButton<T>(
        hint: Text(hint),
        value: value,
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFE17652)),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text(
            'Book Appointment',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFE17652),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<PetpatientDb>(
      future: fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              title: const Text(
                'Book Appointment',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFE17652),
              foregroundColor: Colors.white,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFE17652),
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Text(
                'Error fetching profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          final petpatient = snapshot.data!;

          return Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              title: const Text(
                'Book Appointment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              backgroundColor: const Color(0xFFE17652),
              foregroundColor: Colors.white,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Help'),
                        content: const Text(
                          'Fill in all the required fields to book an appointment for your pet. Make sure to select a doctor and time slot before proceeding.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPatientDetailsCard(petpatient),
                    const SizedBox(height: 20),
                    _buildAppointmentDetailsCard(),
                    const SizedBox(height: 20),
                    _buildTimeSlotCard(),
                    const SizedBox(height: 20),
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
                                  content: Text('Error fetching doctor details: $e'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            final appointmentData = PetAppointmentDb(
                              username: petpatient.name,
                              age: petpatient.age.toString(),
                              gender: petpatient.sex,
                              email: petpatient.email,
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
                              slotId: '', // Initialize with empty string, will be updated by DatabaseService
                            );

                            // Initialize DatabaseService
                            final dbService = DatabaseService(
                              uid: selectedDoctorUid!,
                              startTime: '09:00 AM',
                              endTime: '05:00 PM',
                              availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
                            );

                            // Update slot status and create appointment in one transaction
                            await dbService.updateSlotAndCreateAppointment(
                              doctorId: selectedDoctorUid!,
                              date: DateTime.parse(selectedDateAndTime.split(' at ')[0]),
                              time: selectedDateAndTime.split(' at ')[1],
                              patientId: user.uid,
                              appointmentData: appointmentData.toJson(),
                              appointmentType: 'pet',
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Appointment Booked Successfully!'),
                                backgroundColor: const Color(0xFFE17652),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE17652),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Book Appointment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFE17652),
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text(
                'Unexpected error occurred',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildPatientDetailsCard(PetpatientDb petpatient) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.pets,
                  color: Color(0xFFE17652),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE17652),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', petpatient.name),
            _buildDetailRow('Type', petpatient.type),
            _buildDetailRow('Breed', petpatient.breed),
            _buildDetailRow('Age', '${petpatient.age} years'),
            _buildDetailRow('Gender', petpatient.sex),
            _buildDetailRow('Owner', petpatient.ownerName),
            _buildDetailRow('Contact', petpatient.ownerPhone),
            _buildDetailRow('Email', petpatient.email),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFE17652),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Appointment Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE17652),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDoctors(),
              builder: (context, doctorSnapshot) {
                if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (doctorSnapshot.hasError) {
                  return Text(
                    'Error fetching doctors',
                    style: TextStyle(color: Colors.red),
                  );
                } else if (doctorSnapshot.hasData) {
                  final doctorList = doctorSnapshot.data!;
                  return buildDropdown<String>(
                    hint: 'Select Doctor',
                    value: selectedDoctorUid,
                    items: doctorList.map((doc) => doc['uid'] as String).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedDoctorUid = newValue;
                      });
                    },
                  );
                } else {
                  return const Text('No doctors available');
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonForVisitController,
              decoration: InputDecoration(
                labelText: 'Reason for Visit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE17652)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE17652)),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFFE17652),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Available Slots',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE17652),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Slot:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedDateAndTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                            const SnackBar(
                              content: Text('Please select a doctor first'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE17652),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Select Time Slot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    final randomSuffix = random.nextInt(1000000);
    return '$timestamp-$randomSuffix';
  }
}
