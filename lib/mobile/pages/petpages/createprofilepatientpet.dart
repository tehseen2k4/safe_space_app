import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProfilePatientPet extends StatefulWidget {
  const CreateProfilePatientPet({super.key});

  @override
  _CreateProfilePatientPetState createState() => _CreateProfilePatientPetState();
}

class _CreateProfilePatientPetState extends State<CreateProfilePatientPet> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers for TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

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
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _animationController.dispose();
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
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE17652),
        foregroundColor: Colors.white,
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
                Container(
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
                      const Text(
                        "Create Your Pet Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildFieldCard(
                  title: 'Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Enter pet name'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter pet name'
                        : null,
                  ),
                ),
                _buildFieldCard(
                  title: 'Username',
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: _inputDecoration('Enter username'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a username'
                        : null,
                  ),
                ),
                _buildFieldCard(
                  title: 'Age',
                  child: TextFormField(
                    controller: _ageController,
                    decoration: _inputDecoration('Enter pet age'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter pet age'
                        : null,
                  ),
                ),
                _buildFieldCard(
                  title: 'Gender',
                  child: DropdownButtonFormField<String>(
                    value: _sexController.text.isNotEmpty
                        ? _sexController.text
                        : null,
                    decoration: _inputDecoration('Select pet gender'),
                    items: ['Male', 'Female']
                        .map((sex) =>
                            DropdownMenuItem(value: sex, child: Text(sex)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _sexController.text = value;
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select pet gender'
                        : null,
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (user != null) {
                          final patientProfile = PetpatientDb(
                            name: _nameController.text,
                            username: _usernameController.text,
                            sex: _sexController.text,
                            email: user!.email ?? '',
                            age: int.tryParse(_ageController.text) ?? 0,
                            uid: user!.uid,
                          );

                          await patientProfile.checkAndSaveProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Profile Created Successfully'),
                              backgroundColor: const Color(0xFFE17652),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          Navigator.pop(context, true);
                        }
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
                      'Create Profile',
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
      ),
    );
  }

  Widget _buildFieldCard({
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xB7FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }
}
