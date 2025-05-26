import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/petpatient_db.dart';

class EditPetPatientProfilePage extends StatefulWidget {
  final VoidCallback? onSave;

  const EditPetPatientProfilePage({
    Key? key,
    this.onSave,
  }) : super(key: key);

  @override
  State<EditPetPatientProfilePage> createState() => _EditPetPatientProfilePageState();
}

class _EditPetPatientProfilePageState extends State<EditPetPatientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _sexController = TextEditingController();
  final _neuterStatusController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _trainingStatusController = TextEditingController();
  
  DateTime _dateOfBirth = DateTime.now();
  DateTime _lastVaccination = DateTime.now();
  List<String> _allergies = [];
  List<String> _specialNeeds = [];
  List<String> _dietaryRequirements = [];
  List<String> _groomingNeeds = [];
  bool _isLoading = false;

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
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _sexController.dispose();
    _neuterStatusController.dispose();
    _ownerNameController.dispose();
    _ownerPhoneController.dispose();
    _emergencyContactController.dispose();
    _trainingStatusController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('pets').doc(user.uid);
        final docSnapshot = await docRef.get();
        
        if (docSnapshot.exists) {
          final data = docSnapshot.data()!;
          _nameController.text = data['name'] ?? '';
          _speciesController.text = data['type'] ?? '';
          _breedController.text = data['breed'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _sexController.text = data['sex'] ?? '';
          _neuterStatusController.text = data['neuterStatus'] ?? '';
          _ownerNameController.text = data['ownerName'] ?? '';
          _ownerPhoneController.text = data['ownerPhone'] ?? '';
          _emergencyContactController.text = data['emergencyContact'] ?? '';
          _trainingStatusController.text = data['trainingStatus'] ?? '';
          
          if (data['dateOfBirth'] != null) {
            _dateOfBirth = (data['dateOfBirth'] as Timestamp).toDate();
          }
          if (data['lastVaccination'] != null) {
            _lastVaccination = (data['lastVaccination'] as Timestamp).toDate();
          }
          
          _allergies = List<String>.from(data['allergies'] ?? []);
          _specialNeeds = List<String>.from(data['specialNeeds'] ?? []);
          _dietaryRequirements = List<String>.from(data['dietaryRequirements'] ?? []);
          _groomingNeeds = List<String>.from(data['groomingNeeds'] ?? []);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('No user logged in');
        }

        final petProfile = PetpatientDb(
          name: _nameController.text,
          type: _speciesController.text,
          breed: _breedController.text,
          age: int.parse(_ageController.text),
          sex: _sexController.text,
          dateOfBirth: _dateOfBirth,
          weight: double.parse(_weightController.text),
          neuterStatus: _neuterStatusController.text,
          ownerName: _ownerNameController.text,
          ownerPhone: _ownerPhoneController.text,
          emergencyContact: _emergencyContactController.text,
          email: user.email!,
          uid: user.uid,
          allergies: _allergies,
          specialNeeds: _specialNeeds,
          lastVaccination: _lastVaccination,
          dietaryRequirements: _dietaryRequirements,
          groomingNeeds: _groomingNeeds,
          trainingStatus: _trainingStatusController.text,
        );

        await petProfile.checkAndSaveProfile();

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
              backgroundColor: Colors.teal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          );
          widget.onSave?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
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
            color: Colors.teal,
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
            prefixIcon: Icon(icon, color: Colors.teal),
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
              borderSide: const BorderSide(color: Colors.teal, width: 2),
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
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(
              _getIconForField(label),
              color: Colors.teal,
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
              borderSide: const BorderSide(color: Colors.teal, width: 2),
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
            color: Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime value,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
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
                borderSide: const BorderSide(color: Colors.teal, width: 2),
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

  Future<void> _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> options,
    List<String> selectedItems,
    Function(List<String>) onSelectionChanged,
  ) async {
    List<String> tempSelectedItems = List.from(selectedItems);
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((String option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: tempSelectedItems.contains(option),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedItems.add(option);
                          } else {
                            tempSelectedItems.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Done'),
                  onPressed: () {
                    onSelectionChanged(tempSelectedItems);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
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
            color: Colors.teal,
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
                  color: Colors.teal,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Basic Information
            _buildSection(
              'Basic Information',
              [
                _buildTextField(
                      controller: _nameController,
                  label: 'Pet Name',
                  hint: 'Enter pet name',
                  icon: Icons.pets,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pet\'s name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Species',
                        value: _speciesController.text.isEmpty ? null : _speciesController.text,
                        items: _petTypes,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _speciesController.text = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                      controller: _breedController,
                        label: 'Breed',
                        hint: 'Enter breed',
                        icon: Icons.pets,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the breed';
                        }
                        return null;
                      },
                      ),
                    ),
                  ],
                    ),
                    const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                      controller: _ageController,
                        label: 'Age (years)',
                        hint: 'Enter age',
                        icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the age';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
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
                          return 'Please enter the weight';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      ),
                    ),
                  ],
                    ),
                    const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Sex',
                        value: _sexController.text.isEmpty ? null : _sexController.text,
                        items: _sexOptions,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _sexController.text = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Neuter Status',
                        value: _neuterStatusController.text.isEmpty ? null : _neuterStatusController.text,
                        items: _neuterStatusOptions,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _neuterStatusController.text = value);
                          }
                        },
                      ),
                    ),
                  ],
                    ),
                    const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Date of Birth',
                        value: _dateOfBirth,
                        onChanged: (date) {
                          setState(() => _dateOfBirth = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        label: 'Last Vaccination',
                        value: _lastVaccination,
                        onChanged: (date) {
                          setState(() => _lastVaccination = date);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Owner Information
            _buildSection(
              'Owner Information',
              [
                _buildTextField(
                  controller: _ownerNameController,
                  label: 'Owner Name',
                  hint: 'Enter owner name',
                  icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the owner name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                      controller: _ownerPhoneController,
                        label: 'Owner Phone',
                        hint: 'Enter phone number',
                        icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the owner phone number';
                        }
                        return null;
                      },
                    ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                      controller: _emergencyContactController,
                        label: 'Emergency Contact',
                        hint: 'Enter emergency contact',
                        icon: Icons.emergency_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the emergency contact';
                        }
                        return null;
                      },
                    ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Medical Information
            _buildSection(
              'Medical Information',
              [
                _buildMultiSelectField(
                  label: 'Allergies',
                  selectedItems: _allergies,
                  items: _allergyOptions,
                  onChanged: (items) {
                    setState(() => _allergies = items);
                      },
                    ),
                    const SizedBox(height: 16),
                _buildMultiSelectField(
                  label: 'Special Needs',
                  selectedItems: _specialNeeds,
                  items: _specialNeedsOptions,
                  onChanged: (items) {
                    setState(() => _specialNeeds = items);
                                  },
                                ),
                              ],
                            ),
            const SizedBox(height: 24),
            // Care Information
            _buildSection(
              'Care Information',
              [
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
                    const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Dietary Requirements',
                  value: _dietaryRequirements.isEmpty ? null : _dietaryRequirements.first,
                  items: _dietaryOptions,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _dietaryRequirements = [value]);
                    }
                  },
                    ),
                    const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Grooming Needs',
                  value: _groomingNeeds.isEmpty ? null : _groomingNeeds.first,
                  items: _groomingOptions,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _groomingNeeds = [value]);
                                    }
                                  },
                                ),
                              ],
            ),
          ],
        ),
      ),
    );
  }
} 