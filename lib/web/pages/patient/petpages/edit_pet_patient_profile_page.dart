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
            const SnackBar(content: Text('Profile saved successfully')),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Pet Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pet\'s name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _speciesController,
                      decoration: const InputDecoration(
                        labelText: 'Species',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the species';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _breedController,
                      decoration: const InputDecoration(
                        labelText: 'Breed',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the breed';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age (years)',
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sexController,
                      decoration: const InputDecoration(
                        labelText: 'Sex',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the sex';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _neuterStatusController,
                      decoration: const InputDecoration(
                        labelText: 'Neuter Status',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the neuter status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the owner name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ownerPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the owner phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the emergency contact';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _trainingStatusController,
                      decoration: const InputDecoration(
                        labelText: 'Training Status',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the training status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date of Birth'),
                      subtitle: Text(_dateOfBirth.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _dateOfBirth = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Last Vaccination'),
                      subtitle: Text(_lastVaccination.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _lastVaccination,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _lastVaccination = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Allergies',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final controller = TextEditingController();
                                    final result = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Add Allergy'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            labelText: 'Allergy',
                                          ),
                                          onSubmitted: (value) {
                                            Navigator.pop(context, value);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, controller.text);
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (result != null && result.isNotEmpty) {
                                      setState(() {
                                        _allergies.add(result);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: _allergies.map((allergy) {
                                return Chip(
                                  label: Text(allergy),
                                  onDeleted: () {
                                    setState(() {
                                      _allergies.remove(allergy);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Special Needs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final controller = TextEditingController();
                                    final result = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Add Special Need'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            labelText: 'Special Need',
                                          ),
                                          onSubmitted: (value) {
                                            Navigator.pop(context, value);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, controller.text);
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (result != null && result.isNotEmpty) {
                                      setState(() {
                                        _specialNeeds.add(result);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: _specialNeeds.map((need) {
                                return Chip(
                                  label: Text(need),
                                  onDeleted: () {
                                    setState(() {
                                      _specialNeeds.remove(need);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Dietary Requirements',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final controller = TextEditingController();
                                    final result = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Add Dietary Requirement'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            labelText: 'Dietary Requirement',
                                          ),
                                          onSubmitted: (value) {
                                            Navigator.pop(context, value);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, controller.text);
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (result != null && result.isNotEmpty) {
                                      setState(() {
                                        _dietaryRequirements.add(result);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: _dietaryRequirements.map((requirement) {
                                return Chip(
                                  label: Text(requirement),
                                  onDeleted: () {
                                    setState(() {
                                      _dietaryRequirements.remove(requirement);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grooming Needs',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final controller = TextEditingController();
                                    final result = await showDialog<String>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Add Grooming Need'),
                                        content: TextField(
                                          controller: controller,
                                          decoration: const InputDecoration(
                                            labelText: 'Grooming Need',
                                          ),
                                          onSubmitted: (value) {
                                            Navigator.pop(context, value);
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, controller.text);
                                            },
                                            child: const Text('Add'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (result != null && result.isNotEmpty) {
                                      setState(() {
                                        _groomingNeeds.add(result);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 8,
                              children: _groomingNeeds.map((need) {
                                return Chip(
                                  label: Text(need),
                                  onDeleted: () {
                                    setState(() {
                                      _groomingNeeds.remove(need);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 