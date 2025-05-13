import 'package:flutter/material.dart';
import 'package:safe_space_app/services/auth_service.dart';
import 'package:safe_space_app/models/users_db.dart';
import 'package:safe_space_app/services/database_service.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/patientlogin.dart';
import 'dart:developer' as developer;

class SignupPagep extends StatefulWidget {
  const SignupPagep({Key? key}) : super(key: key);

  @override
  State<SignupPagep> createState() => _SigninPageState();
}

class _SigninPageState extends State<SignupPagep> {
  final _auth = AuthService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : (isTablet ? 600 : screenSize.width),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 20 : 24),
                vertical: isDesktop ? 40 : 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1976D2)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),
                    // Header Section
                    const Icon(
                      Icons.person_add_rounded,
                      size: 60,
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Create Patient Account',
                      style: TextStyle(
                        fontSize: isDesktop ? 36 : (isTablet ? 32 : 28),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join our healthcare community',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Form Fields
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      isDesktop: isDesktop,
                    ),
                    SizedBox(height: isDesktop ? 24 : 20),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      isDesktop: isDesktop,
                    ),
                    SizedBox(height: isDesktop ? 24 : 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      isDesktop: isDesktop,
                    ),
                    SizedBox(height: isDesktop ? 24 : 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      isDesktop: isDesktop,
                    ),
                    SizedBox(height: isDesktop ? 48 : 40),
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 65 : 55,
                      child: ElevatedButton(
                        onPressed: () {
                          _signup();
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Creating your account...')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 24 : 20),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: const Color(0xFF666666),
                            fontSize: isDesktop ? 18 : 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: const Color(0xFF1976D2),
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 18 : 16,
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
    required bool isDesktop,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: isDesktop ? 18 : 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isDesktop ? 18 : 16),
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2), size: isDesktop ? 28 : 24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1976D2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1976D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 16,
          vertical: isDesktop ? 20 : 16,
        ),
      ),
      validator: validator,
    );
  }

  _gotopatientlogin(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => const LoginPage()));

  _signup() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.createUserWithEmailAndPassword(
            _emailController.text, _passwordController.text);

        if (user != null) {
          // Add user data to Firestore with UID as document ID
          // final newUser = UsersDb(
          //   username: _usernameController.text,
          //   emaill: _emailController.text,
          //   password: _passwordController.text,
          //   usertype: 'patient',
          // );

          // Pass the user's UID to the database service
          //DatabaseService().addUser(user.uid, newUser);

          UsersDb uuser = UsersDb(
              username: _usernameController.text,
              emaill: _emailController.text,
              password: _passwordController.text,
              usertype: 'patient');
          uuser.addUserToFirestore(user.uid);

          developer.log("Patient created successfully: ${user.email}");
          _formKey.currentState!.reset();
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          _gotopatientlogin(context);
        }
      } catch (e, stacktrace) {
        developer.log("Error during signup: $e", stackTrace: stacktrace);
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    }
  }

  // _signup() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       final user = await _auth.createUserWithEmailAndPassword(
  //           _emailController.text, _passwordController.text);
  //       if (user != null) {
  //         // Add user data to Firestore with usertype as 'doctor'
  //         final newUser = UsersDb(
  //           username: _usernameController.text,
  //           emaill: _emailController.text,
  //           password: _passwordController.text,
  //           usertype: 'patient',
  //         );
  //         DatabaseService().addUser(newUser);

  //         developer.log("Patient created successfully: ${user.email}");
  //         _formKey.currentState!.reset();
  //         _usernameController.clear();
  //         _emailController.clear();
  //         _passwordController.clear();
  //         _confirmPasswordController.clear();
  //         _gotopatientlogin(context);
  //       }
  //     } catch (e, stacktrace) {
  //       developer.log("Error during signup: $e", stackTrace: stacktrace);
  //       _showErrorDialog("An unexpected error occurred. Please try again.");
  //     }
  //   }
  // }     //////////////////////////////////////        222222

  // _signup() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       final user = await _auth.createUserWithEmailAndPassword(
  //           _emailController.text, _passwordController.text);
  //       if (user != null) {
  //         developer.log("User created successfully: ${user.email}");
  //         // Reset the form and clear controllers
  //         _formKey.currentState!.reset();
  //         _usernameController.clear();
  //         _emailController.clear();
  //         _passwordController.clear();
  //         _confirmPasswordController.clear();
  //         _gotopatientlogin(context);
  //       } else {
  //         developer.log("User creation failed. Received null.");
  //         _showErrorDialog("Failed to create an account. Please try again.");
  //       }
  //     } catch (e, stacktrace) {
  //       developer.log("Error during signup: $e", stackTrace: stacktrace);
  //       _showErrorDialog("An unexpected error occurred. Please try again.");
  //     }
  //   } else {
  //     developer.log("Form validation failed.");
  //   }
  // }

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
}
