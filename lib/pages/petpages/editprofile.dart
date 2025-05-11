import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPagePet extends StatefulWidget {
  const EditPagePet({super.key});

  @override
  _EditPagePetState createState() => _EditPagePetState();
}

class _EditPagePetState extends State<EditPagePet> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Controllers for TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _sexController.dispose();
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

  @override
  void initState() {
    super.initState();

    // Fetch user data and populate controllers
    if (user != null) {
      fetchProfile(user!.uid).then((data) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _sexController.text = data['sex'] ?? '';
        });
      }).catchError((error) {
        print('Error fetching profile: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit',
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
                        "Welcome, ${_nameController.text.isEmpty ? 'User' : _nameController.text}",
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
                        final User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final patientProfile = PetpatientDb(
                            name: _nameController.text,
                            username: _usernameController.text,
                            sex: _sexController.text,
                            email: user.email ?? '',
                            age: int.tryParse(_ageController.text) ?? 0,
                            uid: user.uid,
                          );

                          await patientProfile.checkAndSaveProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Profile Updated Successfully')),
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
                      'Save',
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
