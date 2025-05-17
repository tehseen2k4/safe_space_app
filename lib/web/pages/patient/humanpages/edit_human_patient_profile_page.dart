import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/patients_db.dart';

class EditHumanPatientProfilePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final VoidCallback? onSave;

  const EditHumanPatientProfilePage({
    Key? key,
    this.initialData,
    this.onSave,
  }) : super(key: key);

  @override
  State<EditHumanPatientProfilePage> createState() => _EditHumanPatientProfilePageState();
}

class _EditHumanPatientProfilePageState extends State<EditHumanPatientProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _maritalStatusController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _preferredLanguageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _smokingStatusController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _currentMedicationsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _maritalStatusController.dispose();
    _occupationController.dispose();
    _preferredLanguageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _smokingStatusController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _currentMedicationsController.dispose();
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
      final data = widget.initialData ?? await fetchProfile(user!.uid);
      if (!mounted) return;

      setState(() {
        _nameController.text = data['name'] ?? '';
        _usernameController.text = data['username'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _sexController.text = data['sex'] ?? '';
        _phoneController.text = data['phonenumber'] ?? '';
        _addressController.text = data['address'] ?? '';
        _emergencyContactController.text = data['emergencyContact'] ?? '';
        _maritalStatusController.text = data['maritalStatus'] ?? '';
        _occupationController.text = data['occupation'] ?? '';
        _preferredLanguageController.text = data['preferredLanguage'] ?? '';
        _heightController.text = data['height']?.toString() ?? '';
        _weightController.text = data['weight']?.toString() ?? '';
        _smokingStatusController.text = data['smokingStatus'] ?? '';
        _medicalHistoryController.text = data['medicalHistory'] ?? '';
        _allergiesController.text = (data['allergies'] as List?)?.join(', ') ?? '';
        _currentMedicationsController.text = data['currentMedications'] ?? '';
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

  Future<Map<String, dynamic>> fetchProfile(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('humanpatients')
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal[100],
                    child: const Icon(Icons.person, size: 40, color: Colors.teal),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Personal Information
            _buildSection(
              'Personal Information',
              [
                _buildTextField('Name', _nameController, 'Enter your name'),
                _buildTextField('Username', _usernameController, 'Enter your username'),
                _buildTextField('Email', _emailController, 'Enter your email', isMultiline: false),
                _buildTextField('Bio', _bioController, 'Tell something about yourself', isMultiline: true),
                _buildTextField('Age', _ageController, 'Enter your age'),
                _buildDropdown('Sex', _sexController, ['Male', 'Female']),
                _buildTextField('Phone Number', _phoneController, 'Enter your phone number'),
                _buildTextField('Address', _addressController, 'Enter your address'),
                _buildTextField('Emergency Contact', _emergencyContactController, 'Enter emergency contact number'),
                _buildDropdown('Marital Status', _maritalStatusController, ['Single', 'Married', 'Divorced', 'Widowed']),
                _buildTextField('Occupation', _occupationController, 'Enter your occupation'),
                _buildDropdown('Preferred Language', _preferredLanguageController, ['English', 'Spanish', 'French', 'German']),
              ],
            ),
            const SizedBox(height: 24),
            // Physical Information
            _buildSection(
              'Physical Information',
              [
                _buildTextField('Height (cm)', _heightController, 'Enter your height'),
                _buildTextField('Weight (kg)', _weightController, 'Enter your weight'),
                _buildDropdown('Smoking Status', _smokingStatusController, ['Never Smoked', 'Former Smoker', 'Current Smoker']),
              ],
            ),
            const SizedBox(height: 24),
            // Medical Information
            _buildSection(
              'Medical Information',
              [
                _buildTextField('Medical History', _medicalHistoryController, 'Enter your medical history', isMultiline: true),
                _buildTextField('Allergies', _allergiesController, 'Enter your allergies (comma-separated)', isMultiline: true),
                _buildTextField('Current Medications', _currentMedicationsController, 'Enter your current medications', isMultiline: true),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
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
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
          ),
          hintStyle: const TextStyle(fontSize: 14),
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

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Calculate BMI
        double height = double.tryParse(_heightController.text) ?? 0;
        double weight = double.tryParse(_weightController.text) ?? 0;
        double bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

        await FirebaseFirestore.instance.collection('humanpatients').doc(user!.uid).set({
          'uid': user!.uid,
          'name': _nameController.text,
          'username': _usernameController.text,
          'bio': _bioController.text,
          'email': _emailController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'sex': _sexController.text,
          'phonenumber': _phoneController.text,
          'address': _addressController.text,
          'emergencyContact': _emergencyContactController.text,
          'maritalStatus': _maritalStatusController.text,
          'occupation': _occupationController.text,
          'preferredLanguage': _preferredLanguageController.text,
          'height': height,
          'weight': weight,
          'bmi': bmi,
          'smokingStatus': _smokingStatusController.text,
          'medicalHistory': _medicalHistoryController.text,
          'allergies': _allergiesController.text.split(',').map((e) => e.trim()).toList(),
          'currentMedications': _currentMedicationsController.text,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          // Call the onSave callback to update the dashboard
          if (widget.onSave != null) {
            widget.onSave!();
          }
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
} 