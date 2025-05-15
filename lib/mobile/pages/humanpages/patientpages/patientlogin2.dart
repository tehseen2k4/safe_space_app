import 'package:flutter/material.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/humanpatientprofile.dart';
import 'package:safe_space_app/mobile/pages/petpages/petpatientprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/petpages/createprofilepatientpet.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/createprofilepatienthuman.dart';

class PatientLogin extends StatefulWidget {
  const PatientLogin({super.key});

  @override
  State<PatientLogin> createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 24),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            actionsPadding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
            title: Column(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                  radius: 28,
                  child: const Icon(Icons.logout, color: Color(0xFF1976D2), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to log out?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        return shouldLogout ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header Section
                    const Icon(
                      Icons.health_and_safety_rounded,
                      size: 60,
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SAFE-SPACE',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choose Your Care Type',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Human Patient Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          print("Human button pressed");
                          final user = FirebaseAuth.instance.currentUser;
                          print("Current user: ${user?.uid}");
                          
                          if (user != null) {
                            try {
                              print("Starting Firestore query for human profile...");
                              final querySnapshot = await FirebaseFirestore.instance
                                  .collection('humanpatients')
                                  .where('uid', isEqualTo: user.uid)
                                  .get();

                              print("Query completed. Documents found: ${querySnapshot.docs.length}");
                              
                              // Print all documents for debugging
                              for (var doc in querySnapshot.docs) {
                                print("Document ID: ${doc.id}");
                                print("Document data: ${doc.data()}");
                              }

                              if (querySnapshot.docs.isNotEmpty) {
                                print("Found human profile, navigating to HumanPatientProfile");
                                if (mounted) {
                                  await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HumanPatientProfile(),
                                    ),
                                  );
                                }
                              } else {
                                print("No human profile found, showing create profile dialog");
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        titlePadding: const EdgeInsets.only(top: 24),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
                                        title: Column(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                                              radius: 28,
                                              child: const Icon(Icons.person_outline, color: Color(0xFF1976D2), size: 32),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Create Profile',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Color(0xFF1976D2),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          'You need to create a profile first to access human healthcare services.',
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: const Color(0xFF1976D2),
                                                      side: const BorderSide(color: Color(0xFF1976D2)),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF1976D2),
                                                      foregroundColor: Colors.white,
                                                      elevation: 2,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => const EditPageHuman(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Create',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            } catch (e, stackTrace) {
                              print("Error checking human profile: $e");
                              print("Stack trace: $stackTrace");
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error checking human profile: ${e.toString()}'),
                                    backgroundColor: const Color(0xFF1976D2),
                                  ),
                                );
                              }
                            }
                          } else {
                            print("No user found");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please sign in to access human services'),
                                  backgroundColor: Color(0xFF1976D2),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: const [
                                Text(
                                  'Human',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Access human healthcare services',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Pet Patient Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: ElevatedButton(
                        onPressed: () async {
                          print("Pet button pressed");
                          final user = FirebaseAuth.instance.currentUser;
                          print("Current user: ${user?.uid}");
                          
                          if (user != null) {
                            try {
                              print("Starting Firestore query...");
                              final querySnapshot = await FirebaseFirestore.instance
                                  .collection('pets')
                                  .where('uid', isEqualTo: user.uid)
                                  .get();

                              print("Query completed. Documents found: ${querySnapshot.docs.length}");
                              
                              // Print all documents for debugging
                              for (var doc in querySnapshot.docs) {
                                print("Document ID: ${doc.id}");
                                print("Document data: ${doc.data()}");
                              }

                              if (querySnapshot.docs.isNotEmpty) {
                                print("Found pet profile, navigating to Petpatientprofile");
                                if (mounted) {
                                  await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Petpatientprofile(),
                                    ),
                                  );
                                }
                              } else {
                                print("No pet profile found, showing create profile dialog");
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        titlePadding: const EdgeInsets.only(top: 24),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        actionsPadding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
                                        title: Column(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                                              radius: 28,
                                              child: const Icon(Icons.pets, color: Color(0xFF1976D2), size: 32),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'Create Pet Profile',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Color(0xFF1976D2),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        content: const Text(
                                          'You need to create a pet profile first to access pet healthcare services.',
                                          style: TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: const Color(0xFF1976D2),
                                                      side: const BorderSide(color: Color(0xFF1976D2)),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF1976D2),
                                                      foregroundColor: Colors.white,
                                                      elevation: 2,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => const CreateProfilePatientPet(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text(
                                                      'Create',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            } catch (e, stackTrace) {
                              print("Error checking pet profile: $e");
                              print("Stack trace: $stackTrace");
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error checking pet profile: ${e.toString()}'),
                                    backgroundColor: const Color(0xFFE17652),
                                  ),
                                );
                              }
                            }
                          } else {
                            print("No user found");
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please sign in to access pet services'),
                                  backgroundColor: Color(0xFFE17652),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.pets,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: const [
                                Text(
                                  'Pet',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Access pet healthcare services',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Footer Description
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: const [
                          Text(
                            'Comprehensive Healthcare Solutions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Expert medical care for both you and your beloved pets, available 24/7 at your convenience.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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
}
