import 'package:flutter/material.dart';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/viewprofilehuman.dart';

class EditPageHuman extends StatefulWidget {
  const EditPageHuman({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPageHuman> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers for TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _bloodgroupController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _maritalStatusController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _preferredLanguageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _smokingStatusController = TextEditingController();
  List<String> _selectedDietaryRestrictions = [];
  List<String> _selectedAllergies = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    if (user != null) {
      fetchProfile(user!.uid).then((data) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _bloodgroupController.text = data['bloodgroup'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _sexController.text = data['sex'] ?? '';
          _phonenumberController.text = data['phonenumber'] ?? '';
          _addressController.text = data['address'] ?? '';
          _emergencyContactController.text = data['emergencyContact'] ?? '';
          _maritalStatusController.text = data['maritalStatus'] ?? '';
          _occupationController.text = data['occupation'] ?? '';
          _preferredLanguageController.text = data['preferredLanguage'] ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _smokingStatusController.text = data['smokingStatus'] ?? '';
          _selectedDietaryRestrictions = List<String>.from(data['dietaryRestrictions'] ?? []);
          _selectedAllergies = List<String>.from(data['allergies'] ?? []);
        });
      }).catchError((error) {
        print('Error fetching profile: $error');
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _bloodgroupController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _phonenumberController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _maritalStatusController.dispose();
    _occupationController.dispose();
    _preferredLanguageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _smokingStatusController.dispose();
    _animationController.dispose();
    super.dispose();
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
      throw Exception('Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileImageSection(),
                  const SizedBox(height: 24),
                  _buildFormSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: const Color(0xFF1976D2),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Change Profile Picture',
            style: TextStyle(
              color: Color(0xFF1976D2),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Information'),
          _buildFormField(
            label: 'Full Name',
            hint: 'Enter your full name',
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Bio',
            hint: 'Tell something about yourself',
            controller: _bioController,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Age',
            hint: 'Enter your age',
            controller: _ageController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Blood Group',
            value: _bloodgroupController.text.isNotEmpty ? _bloodgroupController.text : null,
            items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
            onChanged: (value) {
              if (value != null) _bloodgroupController.text = value;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Gender',
            value: _sexController.text.isNotEmpty ? _sexController.text : null,
            items: ['Male', 'Female'],
            onChanged: (value) {
              if (value != null) _sexController.text = value;
            },
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Contact Information'),
          _buildFormField(
            label: 'Phone Number',
            hint: 'Enter your phone number',
            controller: _phonenumberController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Address',
            hint: 'Enter your address',
            controller: _addressController,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Emergency Contact',
            hint: 'Enter emergency contact number',
            controller: _emergencyContactController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter emergency contact';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Personal Information'),
          _buildDropdownField(
            label: 'Marital Status',
            value: _maritalStatusController.text.isNotEmpty ? _maritalStatusController.text : null,
            items: ['Single', 'Married', 'Divorced', 'Widowed'],
            onChanged: (value) {
              if (value != null) _maritalStatusController.text = value;
            },
          ),
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Occupation',
            hint: 'Enter your occupation',
            controller: _occupationController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your occupation';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Preferred Language',
            value: _preferredLanguageController.text.isNotEmpty ? _preferredLanguageController.text : null,
            items: ['English', 'Hindi', 'Spanish', 'French', 'German', 'Chinese', 'Japanese', 'Arabic'],
            onChanged: (value) {
              if (value != null) _preferredLanguageController.text = value;
            },
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Physical Information'),
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Height (cm)',
                  hint: 'Enter height',
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter height';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Weight (kg)',
                  hint: 'Enter weight',
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter weight';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Medical Information'),
          _buildDropdownField(
            label: 'Smoking Status',
            value: _smokingStatusController.text.isNotEmpty ? _smokingStatusController.text : null,
            items: ['Never Smoked', 'Former Smoker', 'Current Smoker'],
            onChanged: (value) {
              if (value != null) _smokingStatusController.text = value;
            },
          ),
          const SizedBox(height: 16),
          _buildMultiSelectField(
            label: 'Dietary Restrictions',
            selectedItems: _selectedDietaryRestrictions,
            items: [
              'Vegetarian',
              'Vegan',
              'Gluten-Free',
              'Lactose-Free',
              'Halal',
              'Kosher',
              'No Nuts',
              'No Shellfish',
              'No Eggs',
              'No Dairy',
            ],
            onChanged: (items) {
              setState(() {
                _selectedDietaryRestrictions = items;
              });
            },
          ),
          const SizedBox(height: 16),
          _buildMultiSelectField(
            label: 'Allergies',
            selectedItems: _selectedAllergies,
            items: [
              'None',
              'Pollen',
              'Dust',
              'Pet Dander',
              'Peanuts',
              'Shellfish',
              'Dairy',
              'Eggs',
              'Soy',
              'Wheat',
              'Latex',
              'Penicillin',
              'Other',
            ],
            onChanged: (items) {
              setState(() {
                _selectedAllergies = items;
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1976D2),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF1976D2),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> items,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final result = await showDialog<List<String>>(
              context: context,
              builder: (context) => MultiSelectDialog(
                title: label,
                items: items,
                selectedItems: selectedItems,
              ),
            );
            if (result != null) {
              onChanged(result);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? 'Select $label'
                        : selectedItems.join(', '),
                    style: TextStyle(
                      color: selectedItems.isEmpty ? Colors.grey[400] : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF1976D2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Calculate BMI
        double height = double.tryParse(_heightController.text) ?? 0;
        double weight = double.tryParse(_weightController.text) ?? 0;
        double bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

        final patientProfile = PatientsDb(
          name: _nameController.text,
          age: int.tryParse(_ageController.text) ?? 0,
          sex: _sexController.text,
          email: user.email ?? '',
          bloodgroup: _bloodgroupController.text,
          uid: user.uid,
          phonenumber: _phonenumberController.text,
          address: _addressController.text,
          emergencyContact: _emergencyContactController.text,
          maritalStatus: _maritalStatusController.text,
          occupation: _occupationController.text,
          preferredLanguage: _preferredLanguageController.text,
          height: height,
          weight: weight,
          bmi: bmi,
          smokingStatus: _smokingStatusController.text,
          dietaryRestrictions: _selectedDietaryRestrictions,
          allergies: _selectedAllergies,
          bio: _bioController.text,
        );

        await patientProfile.checkAndSaveProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF1976D2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProfileHumanScreen(),
            ),
          );
        }
      }
    }
  }
}

class MultiSelectDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final List<String> selectedItems;

  const MultiSelectDialog({
    Key? key,
    required this.title,
    required this.items,
    required this.selectedItems,
  }) : super(key: key);

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.map((item) {
            return CheckboxListTile(
              title: Text(item),
              value: _selectedItems.contains(item),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedItems),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
