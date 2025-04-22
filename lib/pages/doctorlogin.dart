import 'package:flutter/material.dart';
import 'package:safe_space/models/users_db.dart';
//import 'package:safe_space/services/database_service.dart';
import 'package:safe_space/services/database_service.dart';
import 'doctorprofile.dart';
import 'package:safe_space/auth_service.dart';
import 'package:safe_space/pages/signuppaged.dart';
import 'dart:developer' as developer;

//MaterialPageRoute(builder: (context) => Doctorlogin()),
//import 'patientlogin2.dart'; // Import the PatientLogin page

class Doctorpagee extends StatefulWidget {
  const Doctorpagee({super.key});

  @override
  State<Doctorpagee> createState() => _LoginPageState();
}

class _LoginPageState extends State<Doctorpagee> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _mailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                TextFormField(
                  controller: _mailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),
                ElevatedButton(
                  onPressed: _login, // Call the login method here
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.loginUserWithEmailAndPassword(
            _mailController.text, _passwordController.text);
        if (user != null) {
          developer.log("User logged in successfully: ${user.email}");
          //developer.log("User logged in successfully: ${user.uid}");
          final userType = await UsersDb.getUserTypeByUid(user.uid);
          if (userType == 'doctor') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Doctor Login Successful !')),
            );
            _gotoDoctorProfile(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed. Invalid UserType.')),
            );
            //developer.log("User login failed. Invalid UserType.");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User login failed. Received null.')),
          );
          // developer.log("User login failed. Received null.");
        }
      } catch (e, stacktrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: ')),
        );
        // developer.log("Error during login: $e", stackTrace: stacktrace);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form validation failed (LOGIN).')),
      );
      // developer.log("Form validation failed (LOGIN).");
    }
  }

  void _gotoDoctorProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Doctorlogin()),
    );
  }
}
