import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:safe_space_app/mobile/pages/bookappointment.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_appointments_page.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import 'dart:math';

class PetBookAppointmentPage extends StatefulWidget {
  const PetBookAppointmentPage({Key? key}) : super(key: key);

  @override
  State<PetBookAppointmentPage> createState() => _PetBookAppointmentPageState();
}

class _PetBookAppointmentPageState extends State<PetBookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _selectedVet;
  String? _selectedDay;
  String? _selectedTime;
  String _selectedDateAndTime = "None";
  List<String> _availableDays = [];
  List<Map<String, dynamic>> _availableSlots = [];
  List<Map<String, dynamic>> _vets = [];

  // Form controllers
  final _reasonController = TextEditingController();
  final _typeController = TextEditingController();
  final _urgencyController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final List<String> _appointmentTypes = ['General', 'Specialist', 'Emergency'];
  final List<String> _urgencyLevels = ['Normal', 'Urgent', 'Critical'];

  @override
  void initState() {
    super.initState();
    _loadVets();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _typeController.dispose();
    _urgencyController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadVets() async {
    developer.log('Loading vets...', name: 'PetBookAppointment');
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Veterinary')
          .get();

      developer.log('Found ${querySnapshot.docs.length} vets', name: 'PetBookAppointment');
      
      setState(() {
        _vets = querySnapshot.docs
            .map((doc) => {
                  'uid': doc.id,
                  'username': doc['name'],
                  'specialization': doc['specialization'] ?? 'General',
                })
            .toList();
      });
      developer.log('Vets loaded successfully: ${_vets.length}', name: 'PetBookAppointment');
    } catch (e) {
      developer.log('Error loading vets: $e', name: 'PetBookAppointment', error: e);
      print('Error loading vets: $e');
    }
  }

  Future<void> _loadAvailableSlots(String vetId) async {
    developer.log('Loading available slots for vet: $vetId', name: 'PetBookAppointment');
    setState(() => _isLoading = true);
    try {
      final dbService = DatabaseService(
        uid: vetId,
        startTime: '09:00 AM',
        endTime: '05:00 PM',
        availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      );

      final slotsData = await dbService.fetchSlotsForDoctor(vetId);
      developer.log('Fetched slots data: $slotsData', name: 'PetBookAppointment');
      
      if (slotsData != null) {
        setState(() {
          _availableDays = List<String>.from(slotsData['availableDays'] ?? []);
          _availableSlots = [];
          if (slotsData['slots'] != null) {
            final slots = slotsData['slots'] as Map<String, dynamic>;
            slots.forEach((day, daySlots) {
              final List<dynamic> slotsList = daySlots as List<dynamic>;
              for (var slot in slotsList) {
                if (slot['booked'] == false) {
                  _availableSlots.add({
                    'day': day,
                    'time': slot['time'],
                  });
                }
              }
            });
          }
        });
        developer.log('Available days: $_availableDays', name: 'PetBookAppointment');
        developer.log('Available slots: ${_availableSlots.length}', name: 'PetBookAppointment');
      }
    } catch (e) {
      developer.log('Error loading slots: $e', name: 'PetBookAppointment', error: e);
      print('Error loading slots: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAppointment() async {
    developer.log('Starting pet appointment submission...', name: 'PetBookAppointment');
    developer.log('Form validation state: ${_formKey.currentState?.validate()}', name: 'PetBookAppointment');
    developer.log('Selected vet: $_selectedVet', name: 'PetBookAppointment');
    developer.log('Selected day: $_selectedDay', name: 'PetBookAppointment');
    developer.log('Selected time: $_selectedTime', name: 'PetBookAppointment');
    
    if (!_formKey.currentState!.validate()) {
      developer.log('Form validation failed', name: 'PetBookAppointment');
      return;
    }
    if (_selectedVet == null || _selectedDay == null || _selectedTime == null) {
      developer.log('Missing required fields: vet=$_selectedVet, day=$_selectedDay, time=$_selectedTime', 
        name: 'PetBookAppointment');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vet, day, and time')),
      );
      return;
    }

    setState(() => _isLoading = true);
    developer.log('Loading state set to true', name: 'PetBookAppointment');

    try {
      final user = _auth.currentUser;
      if (user == null) {
        developer.log('User not logged in', name: 'PetBookAppointment');
        throw Exception('User not logged in');
      }
      developer.log('Current user: ${user.uid}', name: 'PetBookAppointment');

      developer.log('Fetching pet data for user: ${user.uid}', name: 'PetBookAppointment');
      final patientDoc = await _firestore
          .collection('pets')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (patientDoc.docs.isEmpty) {
        developer.log('Pet profile not found for user: ${user.uid}', name: 'PetBookAppointment');
        throw Exception('Pet profile not found');
      }

      final patientData = patientDoc.docs.first.data();
      developer.log('Pet data retrieved: ${patientData['name']}', name: 'PetBookAppointment');

      String? vetName;
      try {
        final vetDoc = await _firestore
            .collection('doctors')
            .doc(_selectedVet)
            .get();
        if (vetDoc.exists) {
          vetName = vetDoc['name'];
          developer.log('Vet found: $vetName', name: 'PetBookAppointment');
        } else {
          developer.log('Vet not found with ID: $_selectedVet', name: 'PetBookAppointment');
          throw Exception('Vet not found');
        }
      } catch (e) {
        developer.log('Error fetching vet details: $e', name: 'PetBookAppointment');
        throw Exception('Error fetching vet details: $e');
      }

      final appointmentId = generateAppointmentId();
      developer.log('Generated appointment ID: $appointmentId', name: 'PetBookAppointment');

      // Create appointment
      final appointment = PetAppointmentDb(
        appointmentId: appointmentId,
        doctorUid: _selectedVet!,
        patientUid: user.uid,
        username: patientData['name'],
        email: patientData['email'],
        gender: patientData['sex'],
        phonenumber: _phoneNumberController.text,
        reasonforvisit: _reasonController.text,
        typeofappointment: _typeController.text,
        doctorpreference: vetName!,
        urgencylevel: _urgencyController.text,
        uid: user.uid,
        age: patientData['age'].toString(),
        timeslot: '$_selectedDay at $_selectedTime',
        status: false,
      );

      developer.log('Appointment object created with data:', name: 'PetBookAppointment');
      developer.log('Appointment ID: ${appointment.appointmentId}', name: 'PetBookAppointment');
      developer.log('Vet UID: ${appointment.doctorUid}', name: 'PetBookAppointment');
      developer.log('Pet UID: ${appointment.patientUid}', name: 'PetBookAppointment');
      developer.log('Time Slot: ${appointment.timeslot}', name: 'PetBookAppointment');

      developer.log('Saving appointment to Firestore...', name: 'PetBookAppointment');
      await appointment.saveToFirestore();
      developer.log('Appointment saved successfully', name: 'PetBookAppointment');

      // Update slot status
      final dbService = DatabaseService(
        uid: _selectedVet!,
        startTime: '09:00 AM',
        endTime: '05:00 PM',
        availableDays: _availableDays,
      );
      developer.log('Updating slot status for day: $_selectedDay, time: $_selectedTime', 
        name: 'PetBookAppointment');
      await dbService.updateSlotStatus(_selectedVet!, _selectedDay!, _selectedTime!, true);
      developer.log('Slot status updated successfully', name: 'PetBookAppointment');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        
        developer.log('Resetting form...', name: 'PetBookAppointment');
        // Reset form
        _formKey.currentState?.reset();
        setState(() {
          _selectedVet = null;
          _selectedDay = null;
          _selectedTime = null;
          _selectedDateAndTime = "None";
          _reasonController.clear();
          _typeController.clear();
          _urgencyController.clear();
          _phoneNumberController.clear();
        });
        developer.log('Form reset complete', name: 'PetBookAppointment');
      }
    } catch (e) {
      developer.log('Error booking appointment: $e', name: 'PetBookAppointment', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking appointment: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
      developer.log('Loading state set to false', name: 'PetBookAppointment');
    }
  }

  String generateAppointmentId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(1000000);
    return '$timestamp-$randomSuffix';
  }

  Future<void> _showSlotSelectionDialog() async {
    developer.log('Opening slot selection dialog...', name: 'PetBookAppointment');
    if (_selectedVet == null) {
      developer.log('No vet selected, showing error message', name: 'PetBookAppointment');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a veterinarian first')),
      );
      return;
    }

    developer.log('Loading available slots for vet: $_selectedVet', name: 'PetBookAppointment');
    await _loadAvailableSlots(_selectedVet!);
    developer.log('Available days: $_availableDays', name: 'PetBookAppointment');
    developer.log('Available slots count: ${_availableSlots.length}', name: 'PetBookAppointment');
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF009688),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Time Slot',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF009688),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      developer.log('Slot selection dialog closed', name: 'PetBookAppointment');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_availableDays.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No available slots found',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _availableDays.map((day) {
                        final daySlots = _availableSlots
                            .where((slot) => slot['day'] == day)
                            .toList();
                        
                        developer.log('Processing day: $day with ${daySlots.length} slots', name: 'PetBookAppointment');
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF009688),
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: daySlots.map((slot) {
                                final timeStr = slot['time'] as String;
                                final timeOnly = timeStr.split(' ')[0];
                                developer.log('Creating slot button for time: $timeOnly', name: 'PetBookAppointment');
                                
                                return ElevatedButton(
                                  onPressed: () {
                                    developer.log('Slot selected - Day: $day, Time: $timeOnly', name: 'PetBookAppointment');
                                    setState(() {
                                      _selectedDay = day;
                                      _selectedTime = timeStr;
                                      _selectedDateAndTime = '${_selectedDay} at $timeOnly';
                                    });
                                    developer.log('Updated selected date and time: $_selectedDateAndTime', name: 'PetBookAppointment');
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF009688),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    timeOnly,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<PetpatientDb>(
      future: _fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Color(0xFFE17652),
                ),
                const SizedBox(height: 20),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE17652),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: const Color(0xFFE17652),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No profile data found'));
        }

        final patient = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Details Card
              _buildPatientDetailsCard(patient),
              const SizedBox(height: 24),
              
              // Appointment Details Card
              _buildAppointmentDetailsCard(),
              const SizedBox(height: 24),
              
              // Time Slot Card
              _buildTimeSlotCard(),
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<PetpatientDb> _fetchProfile(String uid) async {
    try {
      developer.log('Fetching pet profile for user: $uid', name: 'PetBookAppointment');
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await _firestore
          .collection('pets')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        developer.log('No pet profile found for user: $uid', name: 'PetBookAppointment');
        throw Exception('Pet profile not found. Please create a pet profile first.');
      }

      final data = querySnapshot.docs.first.data();
      developer.log('Pet profile data retrieved: ${data['name']}', name: 'PetBookAppointment');
      
      // Ensure all required fields have default values if null
      final safeData = {
        'name': data['name'] ?? 'Not Set',
        'type': data['type'] ?? 'Not Set',
        'breed': data['breed'] ?? 'Not Set',
        'age': data['age'] ?? 0,
        'sex': data['sex'] ?? 'Not Set',
        'dateOfBirth': data['dateOfBirth'] ?? Timestamp.now(),
        'weight': data['weight'] ?? 0.0,
        'neuterStatus': data['neuterStatus'] ?? 'Not Set',
        'ownerName': data['ownerName'] ?? 'Not Set',
        'ownerPhone': data['ownerPhone'] ?? 'Not Set',
        'emergencyContact': data['emergencyContact'] ?? 'Not Set',
        'email': user.email ?? 'Not Set',
        'uid': data['uid'] ?? uid,
        'allergies': data['allergies'] ?? <String>[],
        'specialNeeds': data['specialNeeds'] ?? <String>[],
        'lastVaccination': data['lastVaccination'] ?? Timestamp.now(),
        'dietaryRequirements': data['dietaryRequirements'] ?? <String>[],
        'groomingNeeds': data['groomingNeeds'] ?? <String>[],
        'trainingStatus': data['trainingStatus'] ?? 'Not Set',
      };
      
      return PetpatientDb.fromJson(safeData);
    } catch (e) {
      developer.log('Error fetching pet profile: $e', name: 'PetBookAppointment', error: e);
      throw Exception('Error fetching pet profile: $e');
    }
  }

  Widget _buildPatientDetailsCard(PetpatientDb patient) {
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
            Row(
              children: [
                const Icon(
                  Icons.pets,
                  color: Color(0xFF009688),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009688),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', patient.name),
            _buildDetailRow('Type', patient.type),
            _buildDetailRow('Breed', patient.breed),
            _buildDetailRow('Age', '${patient.age} years'),
            _buildDetailRow('Gender', patient.sex),
            _buildDetailRow('Owner', patient.ownerName),
            _buildDetailRow('Contact', patient.ownerPhone),
            _buildDetailRow('Email', patient.email),
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
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF009688),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Appointment Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF009688),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Vet Selection
              DropdownButtonFormField<String>(
                value: _selectedVet,
                decoration: const InputDecoration(
                  labelText: 'Select Veterinarian',
                  border: OutlineInputBorder(),
                ),
                items: _vets.map((vet) {
                  return DropdownMenuItem<String>(
                    value: vet['uid'] as String,
                    child: Text('${vet['username']} - ${vet['specialization']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVet = value;
                    _selectedDay = null;
                    _selectedTime = null;
                  });
                  if (value != null) {
                    _loadAvailableSlots(value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a veterinarian';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Appointment Type
              DropdownButtonFormField<String>(
                value: _typeController.text.isEmpty ? null : _typeController.text,
                decoration: const InputDecoration(
                  labelText: 'Appointment Type',
                  border: OutlineInputBorder(),
                ),
                items: _appointmentTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _typeController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select appointment type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Reason for Visit
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for Visit',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter reason for visit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Urgency Level
              DropdownButtonFormField<String>(
                value: _urgencyController.text.isEmpty ? null : _urgencyController.text,
                decoration: const InputDecoration(
                  labelText: 'Urgency Level',
                  border: OutlineInputBorder(),
                ),
                items: _urgencyLevels.map((level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _urgencyController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select urgency level';
                  }
                  return null;
                },
              ),
            ],
          ),
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
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF009688),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Available Slots',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009688),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    _selectedDateAndTime,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _showSlotSelectionDialog,
                      icon: const Icon(Icons.calendar_today, color: Colors.white),
                      label: const Text(
                        'Select Time Slot',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
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
} 