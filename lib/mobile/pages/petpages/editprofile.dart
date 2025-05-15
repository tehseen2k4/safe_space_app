import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPagePet extends StatefulWidget {
  const EditPagePet({super.key});

  @override
  _EditPagePetState createState() => _EditPagePetState();
}

class _EditPagePetState extends State<EditPagePet> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Basic Information Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _neuterStatusController = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();

  // Owner Information Controllers
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _ownerPhoneController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();

  // Medical Information Controllers
  final TextEditingController _trainingStatusController = TextEditingController();
  DateTime _lastVaccination = DateTime.now();
  List<String> _selectedAllergies = [];
  List<String> _selectedSpecialNeeds = [];
  List<String> _selectedDietaryRequirements = [];
  List<String> _selectedGroomingNeeds = [];

  // Predefined options for dropdowns and multi-select
  final List<String> _petTypes = ['Dog', 'Cat', 'Bird', 'Other'];
  final List<String> _sexOptions = ['Male', 'Female'];
  final List<String> _neuterStatusOptions = ['Neutered/Spayed', 'Not Neutered/Spayed'];
  final List<String> _trainingStatusOptions = ['None', 'Basic', 'Intermediate', 'Advanced'];
  final List<String> _allergyOptions = ['None', 'Food', 'Medication', 'Environmental', 'Other'];
  final List<String> _specialNeedsOptions = ['None', 'Mobility', 'Vision', 'Hearing', 'Behavioral', 'Other'];
  final List<String> _dietaryOptions = ['Regular', 'Prescription', 'Raw', 'Vegetarian', 'Other'];
  final List<String> _groomingOptions = ['Regular', 'Special', 'None'];

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
          _typeController.text = data['type'] ?? '';
          _breedController.text = data['breed'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _sexController.text = data['sex'] ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _neuterStatusController.text = data['neuterStatus'] ?? '';
          _dateOfBirth = (data['dateOfBirth'] as Timestamp?)?.toDate() ?? DateTime.now();
          _ownerNameController.text = data['ownerName'] ?? '';
          _ownerPhoneController.text = data['ownerPhone'] ?? '';
          _emergencyContactController.text = data['emergencyContact'] ?? '';
          _trainingStatusController.text = data['trainingStatus'] ?? '';
          _lastVaccination = (data['lastVaccination'] as Timestamp?)?.toDate() ?? DateTime.now();
          _selectedAllergies = List<String>.from(data['allergies'] ?? []);
          _selectedSpecialNeeds = List<String>.from(data['specialNeeds'] ?? []);
          _selectedDietaryRequirements = List<String>.from(data['dietaryRequirements'] ?? []);
          _selectedGroomingNeeds = List<String>.from(data['groomingNeeds'] ?? []);
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching profile: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _weightController.dispose();
    _neuterStatusController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _emergencyContactController.dispose();
    _trainingStatusController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchProfile(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pets')
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

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth ? _dateOfBirth : _lastVaccination,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _dateOfBirth = picked;
        } else {
          _lastVaccination = picked;
        }
      });
    }
  }

  Future<void> _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> options,
    List<String> selectedItems,
    Function(List<String>) onSelectionChanged,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((String option) {
                return CheckboxListTile(
                  title: Text(option),
                  value: selectedItems.contains(option),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedItems.add(option);
                      } else {
                        selectedItems.remove(option);
                      }
                      onSelectionChanged(selectedItems);
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        backgroundColor: const Color(0xFFE17652),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'Basic Information',
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Name',
                      hint: 'Enter pet name',
                      icon: Icons.pets,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter pet name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Type',
                      value: _typeController.text.isEmpty ? null : _typeController.text,
                      items: _petTypes,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _typeController.text = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _breedController,
                      label: 'Breed',
                      hint: 'Enter breed',
                      icon: Icons.pets,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter breed' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDateField(
                      label: 'Date of Birth',
                      value: _dateOfBirth,
                      onTap: () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ageController,
                            label: 'Age',
                            hint: 'Enter age in years',
                            icon: Icons.cake_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter age' : null,
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
                            validator: (value) => value?.isEmpty ?? true ? 'Please enter weight' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Gender',
                      value: _sexController.text.isEmpty ? null : _sexController.text,
                      items: _sexOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sexController.text = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Neuter Status',
                      value: _neuterStatusController.text.isEmpty ? null : _neuterStatusController.text,
                      items: _neuterStatusOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _neuterStatusController.text = value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'Owner Information',
                  children: [
                    _buildTextField(
                      controller: _ownerNameController,
                      label: 'Owner Name',
                      hint: 'Enter owner name',
                      icon: Icons.person_outline,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter owner name' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _ownerPhoneController,
                      label: 'Owner Phone',
                      hint: 'Enter owner phone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter owner phone' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emergencyContactController,
                      label: 'Emergency Contact',
                      hint: 'Enter emergency contact',
                      icon: Icons.emergency_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value?.isEmpty ?? true ? 'Please enter emergency contact' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionCard(
                  title: 'Medical Information',
                  children: [
                    _buildDateField(
                      label: 'Last Vaccination',
                      value: _lastVaccination,
                      onTap: () => _selectDate(context, false),
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelectField(
                      label: 'Allergies',
                      selectedItems: _selectedAllergies,
                      items: _allergyOptions,
                      onChanged: (items) {
                        setState(() => _selectedAllergies = items);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelectField(
                      label: 'Special Needs',
                      selectedItems: _selectedSpecialNeeds,
                      items: _specialNeedsOptions,
                      onChanged: (items) {
                        setState(() => _selectedSpecialNeeds = items);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelectField(
                      label: 'Dietary Requirements',
                      selectedItems: _selectedDietaryRequirements,
                      items: _dietaryOptions,
                      onChanged: (items) {
                        setState(() => _selectedDietaryRequirements = items);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMultiSelectField(
                      label: 'Grooming Needs',
                      selectedItems: _selectedGroomingNeeds,
                      items: _groomingOptions,
                      onChanged: (items) {
                        setState(() => _selectedGroomingNeeds = items);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Training Status',
                      value: _trainingStatusController.text.isEmpty ? null : _trainingStatusController.text,
                      items: _trainingStatusOptions,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _trainingStatusController.text = value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (user != null) {
                          final patientProfile = PetpatientDb(
                            name: _nameController.text,
                            type: _typeController.text,
                            breed: _breedController.text,
                            age: int.tryParse(_ageController.text) ?? 0,
                            sex: _sexController.text,
                            dateOfBirth: _dateOfBirth,
                            weight: double.tryParse(_weightController.text) ?? 0.0,
                            neuterStatus: _neuterStatusController.text,
                            ownerName: _ownerNameController.text,
                            ownerPhone: _ownerPhoneController.text,
                            emergencyContact: _emergencyContactController.text,
                            email: user!.email ?? '',
                            uid: user!.uid,
                            allergies: _selectedAllergies,
                            specialNeeds: _selectedSpecialNeeds,
                            lastVaccination: _lastVaccination,
                            dietaryRequirements: _selectedDietaryRequirements,
                            groomingNeeds: _selectedGroomingNeeds,
                            trainingStatus: _trainingStatusController.text,
                          );

                          await patientProfile.checkAndSaveProfile();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Profile updated successfully!'),
                                  ],
                                ),
                                backgroundColor: Color(0xFFE17652),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            );
                            Navigator.pop(context, true);
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE17652),
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE17652),
            Color(0x80E4D3BE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.pets,
              size: 50,
              color: const Color(0xFFE17652),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Edit ${_nameController.text.isEmpty ? 'Pet' : _nameController.text}'s Profile",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
                color: Color(0xFFE17652),
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
            color: Color(0xFFE17652),
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
            prefixIcon: Icon(icon, color: const Color(0xFFE17652)),
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
              borderSide: const BorderSide(color: Color(0xFFE17652), width: 2),
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
            color: Color(0xFFE17652),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getIconForField(label),
              color: const Color(0xFFE17652),
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
              borderSide: const BorderSide(color: Color(0xFFE17652), width: 2),
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
            color: Color(0xFFE17652),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE17652),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFFE17652)),
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
                borderSide: const BorderSide(color: Color(0xFFE17652), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            child: Text(
              '${value.day}/${value.month}/${value.year}',
              style: const TextStyle(fontSize: 16),
            ),
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
            color: Color(0xFFE17652),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMultiSelectDialog(
            context,
            label,
            items,
            selectedItems,
            onChanged,
          ),
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
                  color: Color(0xFFE17652),
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
      case 'type':
        return Icons.pets;
      case 'gender':
        return Icons.pets;
      case 'neuter status':
        return Icons.medical_services_outlined;
      case 'training status':
        return Icons.school_outlined;
      default:
        return Icons.arrow_drop_down;
    }
  }
}
