// import 'package:flutter/material.dart';

// class EditPage extends StatefulWidget {
//   @override
//   _EditPageState createState() => _EditPageState();
// }

// class _EditPageState extends State<EditPage> {
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

//   @override
//   void dispose() {
//     // Clean up the controllers when the widget is disposed
//     _nameController.dispose();
//     _usernameController.dispose();
//     _bioController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Profile'),
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

//                 // Bio Field
//                 Text('Bio', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: _bioController,
//                   maxLines: 2,
//                   decoration: _inputDecoration('Tell something about yourself'),
//                 ),
//                 SizedBox(height: 20),

//                 // Email Field
//                 Text('Email', style: _fieldLabelStyle()),
//                 SizedBox(height: 5),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: _inputDecoration('Enter your email'),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return 'Please enter a valid email';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 40),

//                 // Save Button
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState?.validate() ?? false) {
//                         // Here you can handle saving data logic
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text('Profile Updated Successfully')),
//                         );
//                         Navigator.pop(context); // Go back to the previous page
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
