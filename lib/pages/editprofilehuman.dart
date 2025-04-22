// import 'package:flutter/material.dart';
// import 'package:safe_space/models/patients_db.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class EditPageHuman extends StatefulWidget {
//   @override
//   _EditPageState createState() => _EditPageState();
// }

// class _EditPageState extends State<EditPageHuman> {
//   final User? user = FirebaseAuth.instance.currentUser;
//   final _formKey = GlobalKey<FormState>();
//   // Controllers for TextFormFields
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _bioController = TextEditingController();
//   // final TextEditingController _emailController =
//   //     TextEditingController(text: 'urviny@gmail.com');
//   final TextEditingController _bloodgroupController = TextEditingController();
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _sexController = TextEditingController();

//   @override
//   void dispose() {
//     // Clean up the controllers when the widget is disposed
//     _nameController.dispose();
//     _usernameController.dispose();
//     _bioController.dispose();
//     //_emailController.dispose();
//     _bloodgroupController.dispose();
//     _ageController.dispose();
//     _sexController.dispose();
//     super.dispose();
//   }

//   Future<Map<String, dynamic>> fetchProfile(String uid) async {
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('humanpatients')
//           .where('uid', isEqualTo: uid)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         return querySnapshot.docs.first.data() as Map<String, dynamic>;
//       } else {
//         throw Exception('Profile not found.');
//       }
//     } catch (e) {
//       throw Exception('Error fetching profile: $e');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     // Fetch user data and populate controllers
//     if (user != null) {
//       fetchProfile(user!.uid).then((data) {
//         setState(() {
//           _nameController.text = data['name'] ?? '';
//           _usernameController.text = data['username'] ?? '';
//           _bioController.text = data['bio'] ?? '';
//           _bloodgroupController.text = data['bloodgroup'] ?? '';
//           _ageController.text = data['age']?.toString() ?? '';
//           _sexController.text = data['sex'] ?? '';
//         });
//       }).catchError((error) {
//         print('Error fetching profile: $error');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Profile'),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Name Field
//                 Text('Name', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: _inputDecoration('Enter your name'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 // Username Field
//                 Text('Username', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: _usernameController,
//                   decoration: _inputDecoration('Enter your username'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a username';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),

//                 Text('Age', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: _ageController,
//                   decoration: _inputDecoration('Enter your age'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your age';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 //Blood Group Field
//                 Text('Blood Group', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 DropdownButtonFormField<String>(
//                   value: _bloodgroupController.text.isNotEmpty
//                       ? _bloodgroupController.text
//                       : null, // Set initial value if available
//                   decoration: _inputDecoration(
//                       'Select your Blood Group'), // Custom input decoration
//                   items: [
//                     'A+',
//                     'A-',
//                     'B+',
//                     'B-',
//                     'AB+',
//                     'AB-',
//                     'O+',
//                     'O-'
//                   ] // List of Blood Group items
//                       .map((bloodGroup) => DropdownMenuItem<String>(
//                             value: bloodGroup,
//                             child: Text(bloodGroup),
//                           ))
//                       .toList(), // Convert list to DropdownMenuItems
//                   onChanged: (value) {
//                     if (value != null) {
//                       _bloodgroupController.text =
//                           value; // Update controller text
//                     }
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select your Blood Group';
//                     }
//                     return null;
//                   },
//                 ),

//                 SizedBox(height: 20),

//                 // Sex Field
//                 Text('Gender', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 DropdownButtonFormField<String>(
//                   value: _sexController.text.isNotEmpty
//                       ? _sexController.text
//                       : null, // Set initial value if available
//                   decoration: _inputDecoration(
//                       'Select your Gender'), // Use your input decoration
//                   items: ['Male', 'Female']
//                       .map((sex) => DropdownMenuItem<String>(
//                             value: sex,
//                             child: Text(sex),
//                           ))
//                       .toList(), // Map list to DropdownMenuItems
//                   onChanged: (value) {
//                     if (value != null) {
//                       _sexController.text = value; // Update the controller
//                     }
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select your Gender';
//                     }
//                     return null;
//                   },
//                 ),

//                 SizedBox(height: 40),

//                 // Save Button
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState?.validate() ?? false) {
//                         final User? user = FirebaseAuth.instance.currentUser;
//                         // Create a PatientsDb instance with current form data
//                         if (user != null) {
//                           final patientProfile = PatientsDb(
//                             name: _nameController.text,
//                             username: _usernameController.text,
//                             age: int.tryParse(_ageController.text) ??
//                                 0, // Parse age to int
//                             sex: _sexController.text,
//                             email: user.email ??
//                                 '', // Provide an empty string if user.email is null
//                             bloodgroup: _bloodgroupController.text,
//                             uid: user
//                                 .uid, // Replace with the user's unique ID (e.g., Firebase UID)
//                           );

//                           // Save or update the profile in Firestore
//                           await patientProfile.checkAndSaveProfile();

//                           // Show confirmation message
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                                 content: Text('Profile saved successfully!')),
//                           );

//                           Navigator.pop(
//                               context); // Go back to the previous screen
//                         }
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                       backgroundColor: Colors.black, // Button color
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       'Save',
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function for input decoration
//   InputDecoration _inputDecoration(String hintText) {
//     return InputDecoration(
//       hintText: hintText,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: BorderSide(color: Colors.black),
//       ),
//       contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//     );
//   }

//   // Helper function for field labels
//   TextStyle _fieldLabelStyle() {
//     return TextStyle(
//         fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]);
//   }
// }
import 'package:flutter/material.dart';
import 'package:safe_space/models/patients_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

                      Navigator.pop(context);
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
