import 'package:flutter/material.dart';
import 'package:safe_space_app/services/auth_service.dart';
import 'package:safe_space_app/models/users_db.dart';
import 'package:safe_space_app/web/pages/doctor/doctor_dashboard.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/auth_background.dart';
import 'package:safe_space_app/models/doctors_db.dart';
import 'package:safe_space_app/models/appoinment_db_service.dart';

class DoctorAuthPage extends StatefulWidget {
  const DoctorAuthPage({Key? key}) : super(key: key);

  @override
  State<DoctorAuthPage> createState() => _DoctorAuthPageState();
}

class _DoctorAuthPageState extends State<DoctorAuthPage> {
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
    developer.log("=== Starting Doctor Signup Process ===");
    if (_formKey.currentState!.validate()) {
      developer.log("Form validation passed");
      try {
        developer.log("Attempting to create user with email: ${_emailController.text}");
        
        // Show loading indicator
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
          );
        }

        final user = await _auth.createUserWithEmailAndPassword(
            _emailController.text, _passwordController.text);

        developer.log("User creation response received: ${user?.email ?? 'null'}");
        developer.log("User UID: ${user?.uid ?? 'null'}");

        if (user != null) {
          developer.log("User created successfully, proceeding with Firestore document creation");
          
          // Create user document in Firestore
          UsersDb uuser = UsersDb(
              username: _usernameController.text,
              emaill: _emailController.text,
              password: _passwordController.text,
              usertype: 'doctor');
          
          developer.log("Attempting to add user to Firestore with UID: ${user.uid}");
          await uuser.addUserToFirestore(user.uid);
          developer.log("User document created in Firestore successfully");

          // Clear form fields
          developer.log("Clearing form fields");
          _formKey.currentState!.reset();
          _usernameController.clear();
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
          
          if (mounted) {
            // Close loading indicator
            Navigator.pop(context);
            
            developer.log("Widget is mounted, showing success message");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Doctor account created successfully!')),
            );
            
            developer.log("Attempting to show profile creation dialog");
            try {
              await _showProfileCreationDialog(user.uid);
              developer.log("Profile creation dialog completed successfully");
            } catch (dialogError) {
              developer.log("Error showing profile creation dialog: $dialogError");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error showing profile form: $dialogError'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
            
            developer.log("Switching to sign in mode");
            setState(() {
              _isSignIn = true;
            });
          } else {
            developer.log("Widget is not mounted after user creation");
          }
        } else {
          developer.log("User creation returned null");
          if (mounted) {
            Navigator.pop(context); // Close loading indicator
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to create user account'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e, stacktrace) {
        developer.log("=== Error during signup ===");
        developer.log("Error: $e");
        developer.log("Stack trace: $stacktrace");
        if (mounted) {
          Navigator.pop(context); // Close loading indicator
          _showErrorDialog("An unexpected error occurred. Please try again.");
        }
      }
    } else {
      developer.log("Form validation failed");
    }
    developer.log("=== Signup Process Completed ===");
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        developer.log("=== Web Login Attempt ===");
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
          
          if (userType == 'doctor') {
            developer.log("User type verified as doctor");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Doctor Login Successful!')),
            );
            // Navigate to doctor dashboard
            if (mounted) {
              developer.log("Navigating to doctor dashboard");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DoctorDashboard()),
              );
            }
          } else {
            developer.log("Login failed: Invalid user type - $userType");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login failed. Invalid UserType.')),
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
          SnackBar(content: Text(message)),
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

  Future<void> _showProfileCreationDialog(String uid) async {
    developer.log("=== Starting Profile Creation Dialog ===");
    developer.log("UID for profile creation: $uid");
    
    int currentStep = 0;
    final formKey = GlobalKey<FormState>();
    
    // Controllers for profile fields
    final nameController = TextEditingController();
    final specializationController = TextEditingController();
    final qualificationController = TextEditingController();
    final bioController = TextEditingController();
    final ageController = TextEditingController();
    final sexController = TextEditingController();
    final phonenumberController = TextEditingController();
    final clinicNameController = TextEditingController();
    final contactNumberClinicController = TextEditingController();
    final feesController = TextEditingController();
    final doctorTypeController = TextEditingController();
    final experienceController = TextEditingController();
    final licenseNumberController = TextEditingController();

    // Data structures for cascading dropdowns
    final Map<String, List<String>> _humanQualifications = {
      'MBBS': [
        'General Physician',
        'Pediatrician (Child Specialist)',
        'ENT Specialist',
        'Dermatologist',
        'Gynecologist / Obstetrician',
        'Medical Officer',
        'General Surgeon',
        'Family Physician',
        'Emergency Medicine',
        'Public Health Specialist',
        'Internal Medicine (basic level)',
        'House Officer (entry-level)'
      ],
      'MD': [
        'Cardiologist',
        'Pulmonologist',
        'Neurologist',
        'Psychiatrist',
        'Gastroenterologist',
        'Endocrinologist',
        'Nephrologist',
        'Rheumatologist',
        'Internal Medicine Specialist',
        'Oncologist',
        'Hematologist',
        'Infectious Disease Specialist',
        'Geriatric Medicine',
        'Critical Care Specialist'
      ],
      'FCPS': [
        'Orthopedic Surgeon',
        'Urologist',
        'Cardiothoracic Surgeon',
        'General Surgeon',
        'Neurosurgeon',
        'Gynecologist / Obstetrician (Specialist level)',
        'ENT Surgeon',
        'Pediatric Surgeon',
        'Ophthalmologist (Eye Surgeon)',
        'Plastic & Reconstructive Surgeon',
        'Anesthesiologist',
        'Radiologist',
        'Pathologist',
        'Dermatologist (Specialist level)',
        'Oncology (Clinical or Surgical)'
      ],
      'MS': [
        'General Surgeon',
        'Neurosurgeon',
        'Orthopedic Surgeon',
        'Cardiothoracic Surgeon',
        'ENT Surgeon',
        'Plastic Surgeon',
        'Urologist',
        'Ophthalmic Surgeon'
      ],
      'DPT': [
        'Physiotherapist',
        'Rehabilitation Therapist',
        'Sports Injury Specialist',
        'Neuromuscular Therapy',
        'Orthopedic Physiotherapy'
      ],
      'BDS': [
        'General Dentist',
        'Oral & Maxillofacial Surgeon',
        'Orthodontist',
        'Periodontist',
        'Prosthodontist',
        'Endodontist',
        'Pediatric Dentist',
        'Cosmetic Dentist',
        'Dental Radiologist'
      ],
      'PhD': [
        'Medical Researcher',
        'Public Health Expert',
        'Biomedical Scientist',
        'Clinical Trials Specialist',
        'Geneticist',
        'Health Informatics Specialist',
        'Pharmacologist'
      ]
    };

    final Map<String, List<String>> _veterinaryQualifications = {
      'DVM': [
        'General Veterinary Practitioner',
        'Small Animal Veterinarian (Dogs, Cats)',
        'Large Animal Veterinarian (Cattle, Horses, Goats)',
        'Exotic Animal Veterinarian (Rabbits, Reptiles)',
        'Pet Emergency Care',
        'Preventive Medicine',
        'Zoonotic Disease Management',
        'Animal Welfare Advisor'
      ],
      'BVSc': [
        'General Vet Practitioner',
        'Animal Husbandry Specialist',
        'Livestock Health Advisor',
        'Poultry Veterinarian'
      ],
      'MVSc': [
        'Veterinary Surgeon',
        'Veterinary Internal Medicine',
        'Veterinary Pathologist',
        'Veterinary Parasitologist',
        'Veterinary Microbiologist',
        'Veterinary Radiologist',
        'Veterinary Gynecologist',
        'Veterinary Nutritionist',
        'Animal Reproduction Specialist',
        'Livestock Production Specialist',
        'Veterinary Pharmacologist'
      ],
      'PhD': [
        'Research Scientist',
        'Wildlife Disease Expert',
        'Animal Genetics Researcher',
        'Veterinary Public Health Specialist',
        'Epidemiologist (Animal Health)',
        'University Professor (Vet Schools)'
      ]
    };

    // State variables for dropdowns
    String selectedDoctorType = 'Human';
    List<String> availableQualifications = _humanQualifications.keys.toList();
    List<String> availableSpecializations = [];
    String? selectedQualification;
    String? selectedSpecialization;

    // Working hours
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    final Map<String, bool> selectedDays = {
      'Monday': false,
      'Tuesday': false,
      'Wednesday': false,
      'Thursday': false,
      'Friday': false,
      'Saturday': false,
      'Sunday': false,
    };

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Update available specializations when qualification changes
            void updateSpecializations(String? qualification) {
              if (qualification != null) {
                setDialogState(() {
                  if (selectedDoctorType == 'Human') {
                    availableSpecializations = _humanQualifications[qualification] ?? [];
                  } else {
                    availableSpecializations = _veterinaryQualifications[qualification] ?? [];
                  }
                  selectedSpecialization = null;
                  specializationController.clear();
                });
              }
            }

            // Update available qualifications when doctor type changes
            void updateQualifications(String doctorType) {
              setDialogState(() {
                selectedDoctorType = doctorType;
                if (doctorType == 'Human') {
                  availableQualifications = _humanQualifications.keys.toList();
                } else {
                  availableQualifications = _veterinaryQualifications.keys.toList();
                }
                selectedQualification = null;
                selectedSpecialization = null;
                qualificationController.clear();
                specializationController.clear();
                availableSpecializations = [];
              });
            }

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
                          phonenumberController,
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
                        _buildDropdown(
                          'Doctor Type',
                          doctorTypeController,
                          ['Human', 'Veterinary'],
                          onChanged: (value) {
                            if (value != null) {
                              updateQualifications(value);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select doctor type';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Qualification',
                          qualificationController,
                          availableQualifications,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedQualification = value;
                              });
                              updateSpecializations(value);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select qualification';
                            }
                            return null;
                          },
                        ),
                        _buildDropdown(
                          'Specialization',
                          specializationController,
                          availableSpecializations,
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedSpecialization = value;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select specialization';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'License Number',
                          licenseNumberController,
                          'Enter your medical license number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter license number';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Experience',
                          experienceController,
                          'Years of experience',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter experience';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Clinic Name',
                          clinicNameController,
                          'Enter clinic name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter clinic name';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Clinic Contact Number',
                          contactNumberClinicController,
                          'Enter clinic contact number',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter clinic contact number';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          'Consultation Fees',
                          feesController,
                          'Enter consultation fees',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter consultation fees';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid amount';
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
                        _buildAvailableDaysField(context, selectedDays, setDialogState),
                        _buildTimeSelector('Start Time', startTime, (time) {
                          setDialogState(() => startTime = time);
                        }),
                        _buildTimeSelector('End Time', endTime, (time) {
                          setDialogState(() => endTime = time);
                        }),
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
                    // Header
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
                          const Icon(Icons.medical_services, color: Colors.teal),
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
                    // Progress indicator
                    LinearProgressIndicator(
                      value: (currentStep + 1) / 3,
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                    // Form content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: formKey,
                          child: buildStepContent(),
                        ),
                      ),
                    ),
                    // Action buttons
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
                                  // Validate availability
                                  if (startTime == null || endTime == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select working hours'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  if (!selectedDays.values.contains(true)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select at least one working day'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  // Save profile
                                  try {
                                    await FirebaseFirestore.instance.collection('doctors').doc(uid).set({
                                      'uid': uid,
                                      'name': nameController.text,
                                      'bio': bioController.text,
                                      'email': _emailController.text,
                                      'age': int.tryParse(ageController.text) ?? 0,
                                      'sex': sexController.text,
                                      'specialization': selectedSpecialization,
                                      'qualification': selectedQualification,
                                      'licenseNumber': licenseNumberController.text,
                                      'phonenumber': phonenumberController.text,
                                      'clinicName': clinicNameController.text,
                                      'contactNumberClinic': contactNumberClinicController.text,
                                      'fees': double.tryParse(feesController.text) ?? 0.0,
                                      'doctorType': selectedDoctorType,
                                      'experience': experienceController.text,
                                      'availableDays': selectedDays.entries.where((e) => e.value).map((e) => e.key).toList(),
                                      'startTime': startTime?.format(context) ?? '',
                                      'endTime': endTime?.format(context) ?? '',
                                      'maxDaysInAdvance': 30,
                                    });

                                    if (startTime != null && endTime != null) {
                                      final selectedDaysList = selectedDays.entries.where((e) => e.value).map((e) => e.key).toList();
                                      if (selectedDaysList.isNotEmpty) {
                                        final dbService = DatabaseService(
                                          uid: uid,
                                          startTime: startTime!.format(context),
                                          endTime: endTime!.format(context),
                                          availableDays: selectedDaysList,
                                          maxDaysInAdvance: 30,
                                        );
                                        
                                        // Save slots to Firestore
                                        await dbService.saveSlotsToFirestore();
                                        
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Profile and availability slots created successfully!'),
                                              backgroundColor: Colors.green,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Profile created, but no available days selected for slot generation.'),
                                              backgroundColor: Colors.orange,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Profile created, but working hours not set for slot generation.'),
                                            backgroundColor: Colors.orange,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    if (mounted) {
                                      Navigator.pop(context);
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
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

  Widget _buildTimeSelector(String label, TimeOfDay? time, Function(TimeOfDay?) onTimeSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.teal,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (selectedTime != null) {
                onTimeSelected(selectedTime);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              time != null ? time.format(context) : 'Select Time',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDaysField(
    BuildContext context,
    Map<String, bool> selectedDays,
    StateSetter setDialogState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Days',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                Map<String, bool> tempSelectedDays = Map.from(selectedDays);

                return StatefulBuilder(
                  builder: (context, setStateDialog) {
                    return AlertDialog(
                      title: const Text(
                        'Select Available Days',
                        style: TextStyle(fontSize: 20),
                      ),
                      content: SingleChildScrollView(
                        child: Column(
                          children: tempSelectedDays.entries.map((entry) {
                            return CheckboxListTile(
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 16),
                              ),
                              value: entry.value,
                              onChanged: (bool? value) {
                                setStateDialog(() {
                                  tempSelectedDays[entry.key] = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'Save',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedDays.clear();
                              selectedDays.addAll(tempSelectedDays);
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDays.entries
                            .where((entry) => entry.value)
                            .map((entry) => entry.key)
                            .join(', ') ??
                        'Select Days',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.teal,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
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
                                Icons.medical_services,
                                size: 48,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSignIn ? 'Doctor Sign In' : 'Doctor Sign Up',
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