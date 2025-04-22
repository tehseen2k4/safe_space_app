import 'package:flutter/material.dart';
import 'package:safe_space/auth_service.dart';
import 'package:safe_space/models/users_db.dart';
import 'package:safe_space/services/database_service.dart';
import 'package:safe_space/pages/patientlogin.dart';
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
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
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
                const SizedBox(height: 20),
                // Email Field
                TextFormField(
                  controller: _emailController,
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
                // Password Field
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
                const SizedBox(height: 20),
                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    ),
                  ),
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
                const SizedBox(height: 35),
                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    _signup();
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signing up...')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
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
