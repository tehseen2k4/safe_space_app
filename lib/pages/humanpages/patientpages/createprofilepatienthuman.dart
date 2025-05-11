// import 'package:flutter/material.dart';
// import 'package:safe_space/pages/humanpatientprofile.dart';

// class EditPageHuman extends StatefulWidget {
//   @override
//   _EditPageState createState() => _EditPageState();
// }

// class _EditPageState extends State<EditPageHuman> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers for TextFormFields
//   final TextEditingController _nameController =
//       TextEditingController(text: 'viny');
//   final TextEditingController _usernameController =
//       TextEditingController(text: 'urs_viny');
//   final TextEditingController _bioController =
//       TextEditingController(text: 'I Like you');
//   final TextEditingController _emailController =
//       TextEditingController(text: 'urviny@gmail.com');
//   final TextEditingController _bloodgroupController =
//       TextEditingController(text: 'AB+');
//   final TextEditingController _ageController =
//       TextEditingController(text: '20');
//   final TextEditingController _sexController =
//       TextEditingController(text: 'Female');

//   @override
//   void dispose() {
//     // Clean up the controllers when the widget is disposed
//     _nameController.dispose();
//     _usernameController.dispose();
//     _bioController.dispose();
//     _emailController.dispose();
//     _bloodgroupController.dispose();
//     _ageController.dispose();
//     _sexController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isDesktop = screenSize.width > 1200;
//     final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Create Profile',
//           style: TextStyle(
//             fontSize: isDesktop ? 28 : 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         foregroundColor: Colors.white,
//         toolbarHeight: isDesktop ? 80 : 70,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           child: Container(
//             constraints: BoxConstraints(
//               maxWidth: isDesktop ? 800 : (isTablet ? 600 : screenSize.width),
//             ),
//             margin: EdgeInsets.symmetric(
//               horizontal: isDesktop ? 40 : (isTablet ? 20 : 16),
//               vertical: isDesktop ? 40 : 16,
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Name Field
//                   Text('Name', style: _fieldLabelStyle(isDesktop)),
//                   SizedBox(height: isDesktop ? 8 : 5),
//                   TextFormField(
//                     controller: _nameController,
//                     decoration: _inputDecoration('Enter your name', isDesktop),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your name';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: isDesktop ? 24 : 20),

//                   // Username Field
//                   Text('Username', style: _fieldLabelStyle(isDesktop)),
//                   SizedBox(height: isDesktop ? 8 : 5),
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: _inputDecoration('Enter your username', isDesktop),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a username';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: isDesktop ? 24 : 20),

//                   // Bio Field
//                   Text('Bio', style: _fieldLabelStyle(isDesktop)),
//                   SizedBox(height: isDesktop ? 8 : 5),
//                   TextFormField(
//                     controller: _bioController,
//                     maxLines: 2,
//                     decoration: _inputDecoration('Tell something about yourself', isDesktop),
//                   ),
//                   SizedBox(height: isDesktop ? 24 : 20),

//                   // Email Field
//                   Text('Email', style: _fieldLabelStyle(isDesktop)),
//                   SizedBox(height: isDesktop ? 8 : 5),
//                   TextFormField(
//                     controller: _emailController,
//                     decoration: _inputDecoration('Enter your email', isDesktop),
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: isDesktop ? 24 : 20),

//                   // Age Field
//                   Text('Age', style: _fieldLabelStyle(isDesktop)),
//                   SizedBox(height: isDesktop ? 8 : 5),
//                   TextFormField(
//                     controller: _ageController,
//                     decoration: _inputDecoration('Enter your age', isDesktop),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your age';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: isDesktop ? 24 : 20),

//                   // Sex Field
//                   Text('Sex', style: _fieldLabelStyle(isDesktop)),
//                   SizedBox(height: isDesktop ? 8 : 5),
//                   TextFormField(
//                     controller: _sexController,
//                     decoration: _inputDecoration('Enter your Sex', isDesktop),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your Sex';
//                       }
//                       return null;
//                     },
//                   ),
//                   SizedBox(height: isDesktop ? 40 : 32),

//                   // Save Button
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         if (_formKey.currentState?.validate() ?? false) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text('Profile created Successfully')),
//                           );
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => HumanPatientProfile()),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isDesktop ? 60 : 50,
//                           vertical: isDesktop ? 20 : 15,
//                         ),
//                         backgroundColor: Colors.black,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         'Save',
//                         style: TextStyle(
//                           fontSize: isDesktop ? 18 : 16,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function for input decoration
//   InputDecoration _inputDecoration(String hintText, bool isDesktop) {
//     return InputDecoration(
//       hintText: hintText,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.black),
//       ),
//       contentPadding: EdgeInsets.symmetric(
//         horizontal: isDesktop ? 20 : 15,
//         vertical: isDesktop ? 16 : 10,
//       ),
//     );
//   }

//   // Helper function for field labels
//   TextStyle _fieldLabelStyle(bool isDesktop) {
//     return TextStyle(
//       fontSize: isDesktop ? 18 : 16,
//       fontWeight: FontWeight.w500,
//       color: Colors.grey[700],
//     );
//   }
// }
