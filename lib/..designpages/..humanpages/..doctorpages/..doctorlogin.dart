import 'package:flutter/material.dart';
import 'package:safe_space_app/models/users_db.dart';
//import 'package:safe_space/services/database_service.dart';
import 'package:safe_space_app/services/database_service.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/signuppaged.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/doctorprofile.dart';
import 'package:safe_space_app/services/auth_service.dart';
import 'signuppaged.dart';
import 'dart:developer' as developer;

//MaterialPageRoute(builder: (context) => Doctorlogin()),
//import 'patientlogin2.dart'; // Import the PatientLogin page

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isDesktop ? 60 : 40),
                  _buildHeader(isDesktop),
                  SizedBox(height: isDesktop ? 40 : 24),
                  _buildLoginForm(isDesktop),
                  SizedBox(height: isDesktop ? 24 : 16),
                  _buildSignUpLink(context, isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Column(
      children: [
        Icon(
          Icons.medical_services,
          size: isDesktop ? 80 : 60,
          color: Colors.teal,
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        Text(
          'Doctor Login',
          style: TextStyle(
            fontSize: isDesktop ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        SizedBox(height: isDesktop ? 16 : 8),
        Text(
          'Welcome back! Please login to your account.',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isDesktop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 32 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                'Email',
                _mailController,
                Icons.email,
                isDesktop: isDesktop,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              _buildTextField(
                'Password',
                _passwordController,
                Icons.lock,
                isDesktop: isDesktop,
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
              ),
              SizedBox(height: isDesktop ? 24 : 16),
              _buildLoginButton(isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    required bool isDesktop,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(fontSize: isDesktop ? 18 : 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: isDesktop ? 24 : 20),
        labelStyle: TextStyle(fontSize: isDesktop ? 18 : 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 16 : 12,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginButton(bool isDesktop) {
    return ElevatedButton(
      onPressed: _handleLogin,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 32 : 24,
          vertical: isDesktop ? 16 : 12,
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
        ),
      ),
      child: Text(
        'Login',
        style: TextStyle(
          fontSize: isDesktop ? 20 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSignUpLink(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupPage()),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = await _auth.loginUserWithEmailAndPassword(
            _mailController.text, _passwordController.text);
        if (user != null) {
          developer.log("User logged in successfully: ${user.email}");
          final userType = await UsersDb.getUserTypeByUid(user.uid);
          if (userType == 'doctor') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Doctor Login Successful !')),
            );
            _gotoDoctorProfile(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed. Invalid UserType. Expected: doctor, Got: $userType')),
            );
            developer.log("User login failed. Invalid UserType. Expected: doctor, Got: $userType");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User login failed. Received null.')),
          );
          developer.log("User login failed. Received null.");
        }
      } catch (e, stacktrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during login: $e')),
        );
        developer.log("Error during login: $e", stackTrace: stacktrace);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Form validation failed (LOGIN).')),
      );
      developer.log("Form validation failed (LOGIN).");
    }
  }

  void _gotoDoctorProfile(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DoctorProfile()),
    );
  }
}
