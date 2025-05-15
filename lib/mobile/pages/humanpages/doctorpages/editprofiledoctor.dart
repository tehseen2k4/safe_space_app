import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/doctors_db.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';

class EditPageDoctor extends StatefulWidget {
  @override
  _EditPageDoctorState createState() => _EditPageDoctorState();
}

class _EditPageDoctorState extends State<EditPageDoctor> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _contactNumberClinicController =
      TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  final TextEditingController _doctorTypeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();

  final Map<String, bool> _selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Data structures for cascading dropdowns
  final Map<String, List<String>> _humanQualifications = {
    'MBBS': [
      'General Physician',
      'Pediatrician (Child Specialist)',
      'ENT Specialist',
      'Dermatologist',
      'Gynecologist / Obstetrician',
      'Medical Officer',
      'General Surgeon',
      'Family Physician',
      'Emergency Medicine',
      'Public Health Specialist',
      'Internal Medicine (basic level)',
      'House Officer (entry-level)'
    ],
    'MD': [
      'Cardiologist',
      'Pulmonologist',
      'Neurologist',
      'Psychiatrist',
      'Gastroenterologist',
      'Endocrinologist',
      'Nephrologist',
      'Rheumatologist',
      'Internal Medicine Specialist',
      'Oncologist',
      'Hematologist',
      'Infectious Disease Specialist',
      'Geriatric Medicine',
      'Critical Care Specialist'
    ],
    'FCPS': [
      'Orthopedic Surgeon',
      'Urologist',
      'Cardiothoracic Surgeon',
      'General Surgeon',
      'Neurosurgeon',
      'Gynecologist / Obstetrician (Specialist level)',
      'ENT Surgeon',
      'Pediatric Surgeon',
      'Ophthalmologist (Eye Surgeon)',
      'Plastic & Reconstructive Surgeon',
      'Anesthesiologist',
      'Radiologist',
      'Pathologist',
      'Dermatologist (Specialist level)',
      'Oncology (Clinical or Surgical)'
    ],
    'MS': [
      'General Surgeon',
      'Neurosurgeon',
      'Orthopedic Surgeon',
      'Cardiothoracic Surgeon',
      'ENT Surgeon',
      'Plastic Surgeon',
      'Urologist',
      'Ophthalmic Surgeon'
    ],
    'DPT': [
      'Physiotherapist',
      'Rehabilitation Therapist',
      'Sports Injury Specialist',
      'Neuromuscular Therapy',
      'Orthopedic Physiotherapy'
    ],
    'BDS': [
      'General Dentist',
      'Oral & Maxillofacial Surgeon',
      'Orthodontist',
      'Periodontist',
      'Prosthodontist',
      'Endodontist',
      'Pediatric Dentist',
      'Cosmetic Dentist',
      'Dental Radiologist'
    ],
    'PhD': [
      'Medical Researcher',
      'Public Health Expert',
      'Biomedical Scientist',
      'Clinical Trials Specialist',
      'Geneticist',
      'Health Informatics Specialist',
      'Pharmacologist'
    ]
  };

  final Map<String, List<String>> _veterinaryQualifications = {
    'DVM': [
      'General Veterinary Practitioner',
      'Small Animal Veterinarian (Dogs, Cats)',
      'Large Animal Veterinarian (Cattle, Horses, Goats)',
      'Exotic Animal Veterinarian (Rabbits, Reptiles)',
      'Pet Emergency Care',
      'Preventive Medicine',
      'Zoonotic Disease Management',
      'Animal Welfare Advisor'
    ],
    'BVSc': [
      'General Vet Practitioner',
      'Animal Husbandry Specialist',
      'Livestock Health Advisor',
      'Poultry Veterinarian'
    ],
    'MVSc': [
      'Veterinary Surgeon',
      'Veterinary Internal Medicine',
      'Veterinary Pathologist',
      'Veterinary Parasitologist',
      'Veterinary Microbiologist',
      'Veterinary Radiologist',
      'Veterinary Gynecologist',
      'Veterinary Nutritionist',
      'Animal Reproduction Specialist',
      'Livestock Production Specialist',
      'Veterinary Pharmacologist'
    ],
    'PhD': [
      'Research Scientist',
      'Wildlife Disease Expert',
      'Animal Genetics Researcher',
      'Veterinary Public Health Specialist',
      'Epidemiologist (Animal Health)',
      'University Professor (Vet Schools)'
    ]
  };

  List<String> _availableQualifications = [];
  List<String> _availableSpecializations = [];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _phonenumberController.dispose();
    _clinicNameController.dispose();
    _contactNumberClinicController.dispose();
    _feesController.dispose();
    _experienceController.dispose();
    _doctorTypeController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _emailController.text = user!.email ?? '';
      _initializeProfile();
    }
  }

  Future<void> _initializeProfile() async {
    try {
      final data = await fetchProfile(user!.uid);
      if (!mounted) return;

      setState(() {
        // Set basic information
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _sexController.text = data['sex'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _phonenumberController.text = data['phonenumber'] ?? '';
        _clinicNameController.text = data['clinicName'] ?? '';
        _contactNumberClinicController.text = data['contactNumberClinic'] ?? '';
        _feesController.text = data['fees']?.toString() ?? '';
        _experienceController.text = data['experience'] ?? '';
        _licenseNumberController.text = data['licenseNumber'] ?? '';
        
        // Set doctor type and initialize related fields
        _doctorTypeController.text = data['doctorType'] ?? 'Human';
        
        // Initialize qualifications based on doctor type
        if (_doctorTypeController.text == 'Veterinary') {
          _availableQualifications = _veterinaryQualifications.keys.toList();
        } else {
          _availableQualifications = _humanQualifications.keys.toList();
        }
        
        // Set qualification if it exists and is valid
        if (data['qualification'] != null) {
          String qualification = data['qualification'];
          if (_doctorTypeController.text == 'Veterinary') {
            if (_veterinaryQualifications.containsKey(qualification)) {
              _qualificationController.text = qualification;
              _availableSpecializations = _veterinaryQualifications[qualification] ?? [];
            }
          } else {
            if (_humanQualifications.containsKey(qualification)) {
              _qualificationController.text = qualification;
              _availableSpecializations = _humanQualifications[qualification] ?? [];
            }
          }
          
          // Set specialization if it exists and is valid
          if (data['specialization'] != null) {
            String specialization = data['specialization'];
            if (_availableSpecializations.contains(specialization)) {
              _specializationController.text = specialization;
            }
          }
        }
      });
    } catch (error) {
      print('Error initializing profile: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateQualifications() {
    setState(() {
      if (_doctorTypeController.text == 'Human') {
        _availableQualifications = _humanQualifications.keys.toList();
        // Reset qualification and specialization when switching to human
        _qualificationController.text = '';
        _specializationController.text = '';
        _availableSpecializations = [];
      } else if (_doctorTypeController.text == 'Veterinary') {
        _availableQualifications = _veterinaryQualifications.keys.toList();
        // Reset qualification and specialization when switching to veterinary
        _qualificationController.text = '';
        _specializationController.text = '';
        _availableSpecializations = [];
      }
    });
  }

  void _updateSpecializations() {
    setState(() {
      if (_doctorTypeController.text == 'Human' && 
          _humanQualifications.containsKey(_qualificationController.text)) {
        _availableSpecializations = _humanQualifications[_qualificationController.text] ?? [];
      } else if (_doctorTypeController.text == 'Veterinary' && 
                 _veterinaryQualifications.containsKey(_qualificationController.text)) {
        _availableSpecializations = _veterinaryQualifications[_qualificationController.text] ?? [];
      } else {
        _availableSpecializations = [];
      }
      // Reset specialization if it's not in the new list
      if (_specializationController.text.isNotEmpty && 
          !_availableSpecializations.contains(_specializationController.text)) {
        _specializationController.text = '';
      }
    });
  }

  Future<Map<String, dynamic>> fetchProfile(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        throw Exception('Profile not found.');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSectionHeader('Personal Details'),
                _buildCard([
                  _buildTextField('Name', _nameController, 'Enter your name'),
                  _buildTextField('Username', _usernameController, 'Enter your username'),
                  _buildTextField('Email', _emailController, 'Enter your email', isMultiline: false),
                  _buildTextField('Bio', _bioController, 'Tell something about yourself', isMultiline: true),
                  _buildTextField('Age', _ageController, 'Enter your age'),
                  _buildDropdown('Sex', _sexController, ['Male', 'Female']),
                  _buildTextField('Phone Number', _phonenumberController, 'Enter your phone number'),
                ]),
                _buildSectionHeader('Professional Details'),
                _buildCard([
                  _buildDropdown('Doctor Type', _doctorTypeController, ['Human', 'Veterinary']),
                  _buildDropdown('Qualification', _qualificationController, _availableQualifications),
                  _buildDropdown('Specialization', _specializationController, _availableSpecializations),
                  _buildTextField('License Number', _licenseNumberController, 'Enter your medical license number'),
                  _buildTextField('Experience', _experienceController, 'Years of experience'),
                  _buildTextField('Clinic Name', _clinicNameController, 'Enter clinic name'),
                  _buildTextField('Clinic Contact Number', _contactNumberClinicController, 'Enter clinic contact number'),
                  _buildTextField('Consultation Fees', _feesController, 'Enter consultation fees'),
                ]),
                _buildSectionHeader('Availability'),
                _buildCard([
                  _buildAvailableDaysField(context),
                  _buildTimeSelector('Start Time', _startTime),
                  _buildTimeSelector('End Time', _endTime),
                ]),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiline ? 3 : 1,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(fontSize: 16),
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    TextEditingController controller,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(controller.text) ? controller.text : null,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              controller.text = value;
              if (label == 'Doctor Type') {
                _updateQualifications();
              } else if (label == 'Qualification') {
                _updateSpecializations();
              }
            });
          }
        },
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.teal,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay? time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          ElevatedButton(
            onPressed: () => _selectTime(label),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              time != null ? time.format(context) : 'Select Time',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(String label) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        if (label == 'Start Time') {
          _startTime = selectedTime;
        } else {
          _endTime = selectedTime;
        }
      });
    }
  }

  Future<void> _generateAndSaveSlots() async {
    if (_startTime == null || _endTime == null) return;

    final slotDuration = Duration(minutes: 30); // 30-minute slots
    final selectedDays = _selectedDays.entries.where((e) => e.value).map((e) => e.key).toList();

    for (String day in selectedDays) {
      TimeOfDay current = _startTime!;
      while (_timeOfDayToDouble(current) < _timeOfDayToDouble(_endTime!)) {
        final slotStart = current;
        final slotEnd = _addMinutesToTimeOfDay(current, slotDuration.inMinutes);

        // Save slot to Firestore
        await FirebaseFirestore.instance.collection('appointmentSlots').add({
          'doctorUid': user!.uid,
          'day': day,
          'startTime': slotStart.format(context),
          'endTime': slotEnd.format(context),
          'isBooked': false,
        });

        current = slotEnd;
        if (_timeOfDayToDouble(current) > _timeOfDayToDouble(_endTime!)) break;
      }
    }
  }

  double _timeOfDayToDouble(TimeOfDay t) => t.hour + t.minute / 60.0;

  TimeOfDay _addMinutesToTimeOfDay(TimeOfDay time, int minutesToAdd) {
    final totalMinutes = time.hour * 60 + time.minute + minutesToAdd;
    final newHour = totalMinutes ~/ 60;
    final newMinute = totalMinutes % 60;
    return TimeOfDay(hour: newHour, minute: newMinute);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('doctors').doc(user!.uid).set({
          'uid': user!.uid,
          'name': _nameController.text,
          'username': _usernameController.text,
          'bio': _bioController.text,
          'email': _emailController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'sex': _sexController.text,
          'specialization': _specializationController.text,
          'qualification': _qualificationController.text,
          'licenseNumber': _licenseNumberController.text,
          'phonenumber': _phonenumberController.text,
          'clinicName': _clinicNameController.text,
          'contactNumberClinic': _contactNumberClinicController.text,
          'fees': double.tryParse(_feesController.text) ?? 0.0,
          'doctorType': _doctorTypeController.text,
          'experience': _experienceController.text,
          'availableDays': _selectedDays.entries.where((e) => e.value).map((e) => e.key).toList(),
          'startTime': _startTime?.format(context) ?? '',
          'endTime': _endTime?.format(context) ?? '',
        });

        if (_startTime != null && _endTime != null) {
          final selectedDays = _selectedDays.entries.where((e) => e.value).map((e) => e.key).toList();
          if (selectedDays.isNotEmpty) {
            final dbService = DatabaseService(
              uid: user!.uid,
              startTime: _startTime!.format(context),
              endTime: _endTime!.format(context),
              availableDays: selectedDays,
            );
            await dbService.saveSlotsToFirestore();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        print('Error saving profile: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildAvailableDaysField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                Map<String, bool> tempSelectedDays = Map.from(_selectedDays);

                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: const Text(
                        'Select Available Days',
                        style: TextStyle(fontSize: 20),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: tempSelectedDays.entries.map((entry) {
                            return CheckboxListTile(
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 16),
                              ),
                              value: entry.value,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  tempSelectedDays[entry.key] = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedDays.clear();
                              _selectedDays.addAll(tempSelectedDays);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDays.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .join(', ') ??
                        'Select Days',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
