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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
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
                        radius: 40,
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        child: Icon(Icons.person,
                            size: 50,
                            color: const Color.fromARGB(255, 149, 147, 147)),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Welcome, ${_nameController.text.isEmpty ? 'User' : _nameController.text}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                _buildFieldCard(
                  title: 'Name',
                  child: TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('Enter your name'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null,
                  ),
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
                ),
                SizedBox(height: 30),
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

                          // Save or update the profile in Firestore
                          await patientProfile.checkAndSaveProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Profile Updated Successfully')),
                          );
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Save',
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

  // Helper function for field labels
  TextStyle _fieldLabelStyle() {
    return TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87);
  }

  Widget _buildFieldCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black)),
            SizedBox(height: 10),
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
