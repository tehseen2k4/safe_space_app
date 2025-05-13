import 'package:flutter/material.dart';
import 'package:safe_space_app/services/auth_service.dart';
import 'package:safe_space_app/models/users_db.dart';
import 'package:safe_space_app/web/pages/patient/patient_dashboard.dart';
import 'package:safe_space_app/web/pages/pet/pet_dashboard.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class PatientAuthPage extends StatefulWidget {
  const PatientAuthPage({Key? key}) : super(key: key);

  @override
  State<PatientAuthPage> createState() => _PatientAuthPageState();
}

class _PatientAuthPageState extends State<PatientAuthPage> {
  bool _isSignIn = true;
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verifyFirebaseConfig();
  }

  Future<void> _verifyFirebaseConfig() async {
    try {
      developer.log("=== Verifying Firebase Configuration ===");
      final app = Firebase.app();
      developer.log("Firebase app name: ${app.name}");
      developer.log("Firebase options: ${app.options}");
      
      // Check if auth is initialized
      final auth = FirebaseAuth.instance;
      developer.log("Firebase Auth instance: ${auth.app.name}");
      
      // Check current user
      final currentUser = auth.currentUser;
      developer.log("Current user: ${currentUser?.email ?? 'none'}");
    } catch (e) {
      developer.log("Firebase configuration error: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        developer.log("=== Patient Signup Attempt ===");
        developer.log("Email: ${_emailController.text}");
        developer.log("Username: ${_usernameController.text}");
        developer.log("Password length: ${_passwordController.text.length}");

        final user = await _auth.createUserWithEmailAndPassword(
            _emailController.text, _passwordController.text);

        if (user != null) {
          UsersDb uuser = UsersDb(
              username: _usernameController.text,
              emaill: _emailController.text,
              password: _passwordController.text,
              usertype: 'patient');
          await uuser.addUserToFirestore(user.uid);

          developer.log("Patient created successfully: ${user.email}");
          _formKey.currentState!.reset();
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient account created successfully!'),
              backgroundColor: Colors.teal,
            ),
          );
          
          setState(() {
            _isSignIn = true;
          });
        }
      } catch (e, stacktrace) {
        developer.log("Error during signup: $e", stackTrace: stacktrace);
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        developer.log("=== Patient Login Attempt ===");
        developer.log("Email: ${_emailController.text}");
        developer.log("Password length: ${_passwordController.text.length}");
        
        final user = await _auth.loginUserWithEmailAndPassword(
            _emailController.text, _passwordController.text);
        
        developer.log("Login response received: ${user?.email ?? 'null'}");
        developer.log("User UID: ${user?.uid ?? 'null'}");
        
        if (user != null) {
          developer.log("User logged in successfully: ${user.email}");
          developer.log("Fetching user type for UID: ${user.uid}");
          
          final userType = await UsersDb.getUserTypeByUid(user.uid);
          developer.log("User type received: $userType");
          
          if (userType == 'patient') {
            developer.log("User type verified as patient");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Patient Login Successful!'),
                backgroundColor: Colors.teal,
              ),
            );
            if (mounted) {
              developer.log("Navigating to patient dashboard");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PatientDashboard()),
              );
            }
          } else {
            developer.log("Login failed: Invalid user type - $userType");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login failed. Invalid UserType. Expected: patient, Got: $userType'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        developer.log("=== Firebase Auth Error ===");
        developer.log("Error Code: ${e.code}");
        developer.log("Error Message: ${e.message}");
        developer.log("Stack Trace: ${e.stackTrace}");
        
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found with this email.';
            break;
          case 'wrong-password':
            message = 'Wrong password provided.';
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            break;
          case 'user-disabled':
            message = 'This user has been disabled.';
            break;
          default:
            message = 'An error occurred during login: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e, stacktrace) {
        developer.log("=== General Error ===");
        developer.log("Error: $e");
        developer.log("Stack Trace: $stacktrace");
        _showErrorDialog("An error occurred during login: $e");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSignIn ? 'Patient Sign In' : 'Patient Sign Up',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isSignIn) ...[
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30.0)),
                            ),
                          ),
                          obscureText: true,
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
                        if (!_isSignIn) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSignIn ? _login : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _isSignIn ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignIn = !_isSignIn;
                            });
                          },
                          child: Text(
                            _isSignIn
                                ? 'Don\'t have an account? Sign Up'
                                : 'Already have an account? Sign In',
                            style: const TextStyle(
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Testing bypass buttons
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bypassing authentication for human testing...'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PatientDashboard(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'TESTING: Bypass Auth (Human)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bypassing authentication for pet testing...'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PetDashboard(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'TESTING: Bypass Auth (Pet)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 