import 'package:flutter/material.dart';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/viewprofilehuman.dart';

class EditPageHuman extends StatefulWidget {
  const EditPageHuman({super.key});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPageHuman> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  // Controllers for TextFormFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _bloodgroupController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _bloodgroupController.dispose();
    _ageController.dispose();
    _sexController.dispose();
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
  void initState() {
    super.initState();
    if (user != null) {
      fetchProfile(user!.uid).then((data) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _bloodgroupController.text = data['bloodgroup'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _sexController.text = data['sex'] ?? '';
        });
      }).catchError((error) {
        print('Error fetching profile: $error');
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user != null) {
      fetchProfile(user!.uid).then((data) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _usernameController.text = data['username'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _bloodgroupController.text = data['bloodgroup'] ?? '';
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
        title: Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 2, 93, 98),
                      const Color.fromARGB(255, 177, 181, 181)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(255, 172, 209, 200),
                      child: Icon(Icons.person, size: 50, color: Colors.white),
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

              // Profile Form Fields in Cards
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
                title: 'Blood Group',
                child: DropdownButtonFormField<String>(
                  value: _bloodgroupController.text.isNotEmpty
                      ? _bloodgroupController.text
                      : null,
                  decoration: _inputDecoration('Select your Blood Group'),
                  items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                      .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _bloodgroupController.text = value;
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please select your Blood Group'
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

              // Save Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final patientProfile = PatientsDb(
                        name: _nameController.text,
                        username: _usernameController.text,
                        age: int.tryParse(_ageController.text) ?? 0,
                        sex: _sexController.text,
                        email: user.email ?? '',
                        bloodgroup: _bloodgroupController.text,
                        uid: user.uid,
                      );

                      await patientProfile.checkAndSaveProfile();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile saved successfully!')),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewProfileHumanScreen(),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 93, 98),
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
            ],
          ),
        ),
      ),
    );
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
