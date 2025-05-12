import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';

class CreateProfileDoctor extends StatefulWidget {
  @override
  _CreateProfileDoctorState createState() => _CreateProfileDoctorState();
}

class _CreateProfileDoctorState extends State<CreateProfileDoctor> {
  final _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _clinicNameController = TextEditingController();
  final TextEditingController _contactNumberClinicController = TextEditingController();
  final TextEditingController _feesController = TextEditingController();
  final TextEditingController _doctorTypeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _emailController.text = user!.email ?? '';
      // Initialize dropdowns
      _updateQualifications();
    }
  }

  void _updateQualifications() {
    setState(() {
      if (_doctorTypeController.text == 'Human') {
        _availableQualifications = _humanQualifications.keys.toList();
      } else if (_doctorTypeController.text == 'Veterinary') {
        _availableQualifications = _veterinaryQualifications.keys.toList();
      }
      // Reset specialization when qualification changes
      _specializationController.text = '';
      _updateSpecializations();
    });
  }

  void _updateSpecializations() {
    setState(() {
      if (_doctorTypeController.text == 'Human') {
        _availableSpecializations = _humanQualifications[_qualificationController.text] ?? [];
      } else if (_doctorTypeController.text == 'Veterinary') {
        _availableSpecializations = _veterinaryQualifications[_qualificationController.text] ?? [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Save',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiline ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, TextEditingController controller, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: controller.text.isNotEmpty ? controller.text : null,
        onChanged: (value) {
          setState(() {
            controller.text = value ?? '';
            if (label == 'Doctor Type') {
              _updateQualifications();
            } else if (label == 'Qualification') {
              _updateSpecializations();
            }
          });
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }

  Widget _buildTimeSelector(String label, TimeOfDay? time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ElevatedButton(
            onPressed: () => _selectTime(label),
            child: Text(time != null ? time.format(context) : 'Select Time'),
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

  Widget _buildAvailableDaysField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Days', style: _fieldLabelStyle()),
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                Map<String, bool> tempSelectedDays = Map.from(_selectedDays);

                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: Text('Select Available Days'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: tempSelectedDays.entries.map((entry) {
                            return CheckboxListTile(
                              title: Text(entry.key),
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
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text('Save'),
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
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDays.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .join(', ') ??
                        'Select Days',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  TextStyle _fieldLabelStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile created successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create profile: $e')),
        );
      }
    }
  }
}
