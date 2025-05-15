import 'package:flutter/material.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/humanpatientprofile.dart';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditPageHuman extends StatefulWidget {
  const EditPageHuman({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPageHuman> {
  final _formKey = GlobalKey<FormState>();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Create Profile',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  title: 'Basic Information',
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell something about yourself',
                      icon: Icons.description_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ageController,
                      label: 'Age',
                      hint: 'Enter your age',
                      icon: Icons.cake_outlined,
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
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Contact Information',
                  children: [
                    _buildTextField(
                      controller: _phonenumberController,
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter your address',
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact',
                      hint: 'Enter emergency contact number',
                      icon: Icons.emergency_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter emergency contact';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Personal Information',
                  children: [
                    _buildDropdownField(
                      label: 'Marital Status',
                      value: _maritalStatusController.text.isNotEmpty ? _maritalStatusController.text : null,
                      items: ['Single', 'Married', 'Divorced', 'Widowed'],
                      onChanged: (value) {
                        if (value != null) _maritalStatusController.text = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _occupationController,
                      label: 'Occupation',
                      hint: 'Enter your occupation',
                      icon: Icons.work_outline,
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
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Physical Information',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Height (cm)',
                            hint: 'Enter height',
                            icon: Icons.height,
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
                          child: _buildTextField(
                            controller: _weightController,
                            label: 'Weight (kg)',
                            hint: 'Enter weight',
                            icon: Icons.monitor_weight_outlined,
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
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Medical Information',
                  children: [
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
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text(
                      'Save Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
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
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1976D2),
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getIconForField(label),
              color: const Color(0xFF1976D2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select $label';
            }
            return null;
          },
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
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

  IconData _getIconForField(String label) {
    switch (label.toLowerCase()) {
      case 'blood group':
        return Icons.bloodtype_outlined;
      case 'gender':
        return Icons.person_outline;
      case 'marital status':
        return Icons.favorite_outline;
      case 'preferred language':
        return Icons.language_outlined;
      case 'smoking status':
        return Icons.smoking_rooms_outlined;
      default:
        return Icons.arrow_drop_down;
    }
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
                  Text('Profile created successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF1976D2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          Navigator.pop(context, true);
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
