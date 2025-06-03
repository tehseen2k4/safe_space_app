import 'package:flutter/material.dart';
import 'package:safe_space_app/services/auth_service.dart';
import 'package:safe_space_app/models/users_db.dart';
import 'package:safe_space_app/web/pages/patient/humanpages/human_patient_dashboard.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_dashboard.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/auth_background.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/petpatient_db.dart';

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
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Patient account created successfully!'),
                backgroundColor: Colors.teal,
              ),
            );
            
            // Show profile type selection dialog
            _showProfileTypeSelectionDialog(user.uid);
          }
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
              developer.log("Showing dashboard selection dialog");
              _showDashboardSelectionDialog();
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

  void _showDashboardSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.teal,
                        Colors.teal.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SAFE-SPACE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your trusted healthcare companion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDashboardOption(
                      'Human',
                      Icons.person,
                      () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HumanPatientDashboard()),
                        );
                      },
                    ),
                    _buildDashboardOption(
                      'Pet',
                      Icons.pets,
                      () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const PetPatientDashboard()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.withOpacity(0.1),
              Colors.teal.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.teal.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileTypeSelectionDialog(String uid) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.teal,
                        Colors.teal.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create Profiles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need to create both human and pet profiles',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileOption(
                      'Human First',
                      Icons.person,
                      () {
                        Navigator.pop(context);
                        _showHumanProfileCreationDialog(uid, () {
                          _showPetProfileCreationDialog(uid);
                        });
                      },
                    ),
                    _buildProfileOption(
                      'Pet First',
                      Icons.pets,
                      () {
                        Navigator.pop(context);
                        _showPetProfileCreationDialog(uid, () {
                          _showHumanProfileCreationDialog(uid);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.withOpacity(0.1),
              Colors.teal.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.teal.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHumanProfileCreationDialog(String uid, [VoidCallback? onComplete]) async {
    int currentStep = 0;
    final formKey = GlobalKey<FormState>();
    
    // Controllers for profile fields
    final nameController = TextEditingController();
    final bioController = TextEditingController();
    final ageController = TextEditingController();
    final sexController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final emergencyContactController = TextEditingController();
    final maritalStatusController = TextEditingController();
    final occupationController = TextEditingController();
    final preferredLanguageController = TextEditingController();
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final smokingStatusController = TextEditingController();
    final medicalHistoryController = TextEditingController();
    final allergiesController = TextEditingController();
    final currentMedicationsController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildStepContent() {
              switch (currentStep) {
                case 0:
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          'Name',
                          nameController,
                          'Enter your name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Age',
                          ageController,
                          'Enter your age',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Sex',
                          sexController,
                          ['Male', 'Female'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your sex';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Bio',
                          bioController,
                          'Tell something about yourself',
                          isMultiline: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a bio';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Phone Number',
                          phoneController,
                          'Enter your phone number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                case 1:
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          'Address',
                          addressController,
                          'Enter your address',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your address';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Emergency Contact',
                          emergencyContactController,
                          'Enter emergency contact number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter emergency contact';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Marital Status',
                          maritalStatusController,
                          ['Single', 'Married', 'Divorced', 'Widowed'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select marital status';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Occupation',
                          occupationController,
                          'Enter your occupation',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your occupation';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Preferred Language',
                          preferredLanguageController,
                          ['English', 'Spanish', 'French', 'German'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select preferred language';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                case 2:
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          'Height (cm)',
                          heightController,
                          'Enter your height',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid height';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Weight (kg)',
                          weightController,
                          'Enter your weight',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Smoking Status',
                          smokingStatusController,
                          ['Never Smoked', 'Former Smoker', 'Current Smoker'],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select smoking status';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Medical History',
                          medicalHistoryController,
                          'Enter your medical history',
                          isMultiline: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your medical history';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Allergies',
                          allergiesController,
                          'Enter your allergies (comma-separated)',
                          isMultiline: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your allergies';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Current Medications',
                          currentMedicationsController,
                          'Enter your current medications',
                          isMultiline: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your current medications';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 600,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.teal),
                          const SizedBox(width: 10),
                          Text(
                            'Complete Your Profile - Step ${currentStep + 1}/3',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LinearProgressIndicator(
                      value: (currentStep + 1) / 3,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: formKey,
                          child: buildStepContent(),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (currentStep > 0)
                            TextButton(
                              onPressed: () {
                                setDialogState(() => currentStep--);
                              },
                              child: const Text('Back'),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                if (currentStep < 2) {
                                  setDialogState(() => currentStep++);
                                } else {
                                  try {
                                    // Calculate BMI
                                    double height = double.tryParse(heightController.text) ?? 0;
                                    double weight = double.tryParse(weightController.text) ?? 0;
                                    double bmi = height > 0 ? weight / ((height / 100) * (height / 100)) : 0;

                                    await FirebaseFirestore.instance.collection('humanpatients').doc(uid).set({
                                      'uid': uid,
                                      'name': nameController.text,
                                      'username': _usernameController.text,
                                      'bio': bioController.text,
                                      'email': _emailController.text,
                                      'age': int.tryParse(ageController.text) ?? 0,
                                      'sex': sexController.text,
                                      'phonenumber': phoneController.text,
                                      'address': addressController.text,
                                      'emergencyContact': emergencyContactController.text,
                                      'maritalStatus': maritalStatusController.text,
                                      'occupation': occupationController.text,
                                      'preferredLanguage': preferredLanguageController.text,
                                      'height': height,
                                      'weight': weight,
                                      'bmi': bmi,
                                      'smokingStatus': smokingStatusController.text,
                                      'medicalHistory': medicalHistoryController.text,
                                      'allergies': allergiesController.text.split(',').map((e) => e.trim()).toList(),
                                      'currentMedications': currentMedicationsController.text,
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Human profile completed successfully!')),
                                      );
                                      Navigator.pop(context);
                                      if (onComplete != null) {
                                        onComplete();
                                      } else {
                                        setState(() {
                                          _isSignIn = true;
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    print('Error saving profile: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save profile: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(currentStep < 2 ? 'Next' : 'Complete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showPetProfileCreationDialog(String uid, [VoidCallback? onComplete]) async {
    int currentStep = 0;
    final formKey = GlobalKey<FormState>();
    
    // Controllers for profile fields
    final nameController = TextEditingController();
    final speciesController = TextEditingController();
    final breedController = TextEditingController();
    final ageController = TextEditingController();
    final weightController = TextEditingController();
    final sexController = TextEditingController();
    final neuterStatusController = TextEditingController();
    final ownerNameController = TextEditingController();
    final ownerPhoneController = TextEditingController();
    final emergencyContactController = TextEditingController();
    final trainingStatusController = TextEditingController();
    
    DateTime dateOfBirth = DateTime.now();
    DateTime lastVaccination = DateTime.now();
    List<String> allergies = [];
    List<String> specialNeeds = [];
    List<String> dietaryRequirements = [];
    List<String> groomingNeeds = [];

    // Predefined options
    final List<String> petTypes = ['Dog', 'Cat', 'Bird', 'Other'];
    final List<String> sexOptions = ['Male', 'Female'];
    final List<String> neuterStatusOptions = ['Neutered/Spayed', 'Not Neutered/Spayed'];
    final List<String> trainingStatusOptions = ['None', 'Basic', 'Intermediate', 'Advanced'];
    final List<String> allergyOptions = ['None', 'Food', 'Medication', 'Environmental', 'Other'];
    final List<String> specialNeedsOptions = ['None', 'Mobility', 'Vision', 'Hearing', 'Behavioral', 'Other'];
    final List<String> dietaryOptions = ['Regular', 'Prescription', 'Raw', 'Vegetarian', 'Other'];
    final List<String> groomingOptions = ['Regular', 'Special', 'None'];

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildStepContent() {
              switch (currentStep) {
                case 0:
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          'Pet Name',
                          nameController,
                          'Enter pet name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter pet name';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Species',
                          speciesController,
                          petTypes,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select species';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Breed',
                          breedController,
                          'Enter breed',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter breed';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Age (years)',
                          ageController,
                          'Enter age',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter age';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Weight (kg)',
                          weightController,
                          'Enter weight',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter weight';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  );
                case 1:
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildDropdown(
                          'Sex',
                          sexController,
                          sexOptions,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select sex';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Neuter Status',
                          neuterStatusController,
                          neuterStatusOptions,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select neuter status';
                            }
                            return null;
                          },
                        ),
                        _buildDatePicker(
                          'Date of Birth',
                          dateOfBirth,
                          (date) {
                            setDialogState(() => dateOfBirth = date);
                          },
                        ),
                        _buildDatePicker(
                          'Last Vaccination',
                          lastVaccination,
                          (date) {
                            setDialogState(() => lastVaccination = date);
                          },
                        ),
                        _buildMultiSelectField(
                          'Allergies',
                          allergies,
                          allergyOptions,
                          (items) {
                            setDialogState(() => allergies = items);
                          },
                        ),
                        _buildMultiSelectField(
                          'Special Needs',
                          specialNeeds,
                          specialNeedsOptions,
                          (items) {
                            setDialogState(() => specialNeeds = items);
                          },
                        ),
                      ],
                    ),
                  );
                case 2:
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          'Owner Name',
                          ownerNameController,
                          'Enter owner name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter owner name';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Owner Phone',
                          ownerPhoneController,
                          'Enter owner phone number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter owner phone number';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Emergency Contact',
                          emergencyContactController,
                          'Enter emergency contact number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter emergency contact';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Training Status',
                          trainingStatusController,
                          trainingStatusOptions,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select training status';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Dietary Requirements',
                          TextEditingController(text: dietaryRequirements.isEmpty ? null : dietaryRequirements.first),
                          dietaryOptions,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select dietary requirements';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => dietaryRequirements = [value]);
                            }
                          },
                        ),
                        _buildDropdown(
                          'Grooming Needs',
                          TextEditingController(text: groomingNeeds.isEmpty ? null : groomingNeeds.first),
                          groomingOptions,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select grooming needs';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => groomingNeeds = [value]);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 600,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pets, color: Colors.teal),
                          const SizedBox(width: 10),
                          Text(
                            'Complete Pet Profile - Step ${currentStep + 1}/3',
                            style: const TextStyle(
                              color: Colors.teal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LinearProgressIndicator(
                      value: (currentStep + 1) / 3,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: formKey,
                          child: buildStepContent(),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (currentStep > 0)
                            TextButton(
                              onPressed: () {
                                setDialogState(() => currentStep--);
                              },
                              child: const Text('Back'),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                if (currentStep < 2) {
                                  setDialogState(() => currentStep++);
                                } else {
                                  try {
                                    final petProfile = PetpatientDb(
                                      name: nameController.text,
                                      type: speciesController.text,
                                      breed: breedController.text,
                                      age: int.parse(ageController.text),
                                      sex: sexController.text,
                                      dateOfBirth: dateOfBirth,
                                      weight: double.parse(weightController.text),
                                      neuterStatus: neuterStatusController.text,
                                      ownerName: ownerNameController.text,
                                      ownerPhone: ownerPhoneController.text,
                                      emergencyContact: emergencyContactController.text,
                                      email: _emailController.text,
                                      uid: uid,
                                      allergies: allergies,
                                      specialNeeds: specialNeeds,
                                      lastVaccination: lastVaccination,
                                      dietaryRequirements: dietaryRequirements,
                                      groomingNeeds: groomingNeeds,
                                      trainingStatus: trainingStatusController.text,
                                    );

                                    await petProfile.checkAndSaveProfile();

                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Pet profile completed successfully!')),
                                      );
                                      Navigator.pop(context);
                                      if (onComplete != null) {
                                        onComplete();
                                      } else {
                                        setState(() {
                                          _isSignIn = true;
                                        });
                                      }
                                    }
                                  } catch (e) {
                                    print('Error saving profile: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to save profile: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(currentStep < 2 ? 'Next' : 'Complete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isMultiline = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiline ? 3 : 1,
        style: const TextStyle(fontSize: 16),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
          ),
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    TextEditingController controller,
    List<String> items, {
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: DropdownButtonFormField<String>(
        value: items.contains(controller.text) ? controller.text : null,
        onChanged: (value) {
          if (value != null) {
            controller.text = value;
            onChanged?.call(value);
          }
        },
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.teal,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.teal,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime value,
    Function(DateTime) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                onChanged(date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.teal, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                '${value.day}/${value.month}/${value.year}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectField(
    String label,
    List<String> selectedItems,
    List<String> items,
    void Function(List<String>) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showMultiSelectDialog(
              context,
              label,
              items,
              selectedItems,
              onChanged,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedItems.isEmpty
                          ? 'Select $label'
                          : selectedItems.join(', '),
                      style: TextStyle(
                        color: selectedItems.isEmpty ? Colors.grey[400] : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> options,
    List<String> selectedItems,
    Function(List<String>) onSelectionChanged,
  ) async {
    List<String> tempSelectedItems = List.from(selectedItems);
    
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((String option) {
                    return CheckboxListTile(
                      title: Text(option),
                      value: tempSelectedItems.contains(option),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedItems.add(option);
                          } else {
                            tempSelectedItems.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Done'),
                  onPressed: () {
                    onSelectionChanged(tempSelectedItems);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AuthBackground(),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    shadowColor: Colors.teal.withOpacity(0.3),
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
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.teal.withOpacity(0.2),
                                    Colors.teal.withOpacity(0.1),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 48,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSignIn ? 'Patient Sign In' : 'Patient Sign Up',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (!_isSignIn) ...[
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                      color: Colors.teal.withOpacity(0.5),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                      color: Colors.teal.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: const BorderSide(
                                      color: Colors.teal,
                                      width: 2,
                                    ),
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
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                    color: Colors.teal.withOpacity(0.5),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                    color: Colors.teal.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                    width: 2,
                                  ),
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
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                    color: Colors.teal.withOpacity(0.5),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(
                                    color: Colors.teal.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    color: Colors.teal,
                                    width: 2,
                                  ),
                                ),
                              ),
                              obscureText: true,
                              onFieldSubmitted: (_) => _login(),
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
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                      color: Colors.teal.withOpacity(0.5),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide(
                                      color: Colors.teal.withOpacity(0.3),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: const BorderSide(
                                      color: Colors.teal,
                                      width: 2,
                                    ),
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
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                                shadowColor: Colors.teal.withOpacity(0.4),
                              ),
                              child: Text(
                                _isSignIn ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
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
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.teal,
                              ),
                              child: Text(
                                _isSignIn
                                    ? 'Don\'t have an account? Sign Up'
                                    : 'Already have an account? Sign In',
                                style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 0.5,
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
        ],
      ),
    );
  }
} 