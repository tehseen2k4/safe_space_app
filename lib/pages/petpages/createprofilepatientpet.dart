import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProfilePatientPet extends StatefulWidget {
  @override
  _CreateProfilePatientPetState createState() => _CreateProfilePatientPetState();
}

class _CreateProfilePatientPetState extends State<CreateProfilePatientPet> {
  final _formKey = GlobalKey<FormState>();
  final User? user = FirebaseAuth.instance.currentUser;

  // Controllers for TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        foregroundColor: Colors.white,
      ),
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 225, 118, 82),
                        const Color.fromARGB(128, 228, 211, 190)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isDesktop ? 50 : 40,
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        child: Icon(
                          Icons.person,
                          size: isDesktop ? 60 : 50,
                          color: const Color.fromARGB(255, 149, 147, 147),
                        ),
                      ),
                      SizedBox(width: isDesktop ? 24 : 16),
                      Text(
                        "Create Your Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isDesktop ? 32 : 20),

                _buildFieldCard(
                  title: 'Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Enter your name'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
                  isDesktop: isDesktop,
                ),
                _buildFieldCard(
                  title: 'Username',
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: _inputDecoration('Enter your username'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a username'
                        : null,
                  ),
                  isDesktop: isDesktop,
                ),
                _buildFieldCard(
                  title: 'Age',
                  child: TextFormField(
                    controller: _ageController,
                    decoration: _inputDecoration('Enter your age'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your age'
                        : null,
                  ),
                  isDesktop: isDesktop,
                ),
                _buildFieldCard(
                  title: 'Gender',
                  child: DropdownButtonFormField<String>(
                    value: _sexController.text.isNotEmpty
                        ? _sexController.text
                        : null,
                    decoration: _inputDecoration('Select your Gender'),
                    items: ['Male', 'Female']
                        .map((sex) =>
                            DropdownMenuItem(value: sex, child: Text(sex)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) _sexController.text = value;
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please select your Gender'
                        : null,
                  ),
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isDesktop ? 40 : 30),
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
                            SnackBar(content: Text('Profile Created Successfully')),
                          );
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 64 : 50,
                        vertical: isDesktop ? 20 : 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Create Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 18 : 16,
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
    required bool isDesktop,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 20 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 10),
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
      fillColor: const Color.fromARGB(183, 255, 255, 255),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }
}
