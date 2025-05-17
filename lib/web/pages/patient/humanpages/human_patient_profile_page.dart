import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:safe_space_app/web/pages/patient/humanpages/edit_human_patient_profile_page.dart';

class HumanPatientProfilePage extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  final VoidCallback? onEditProfile;

  const HumanPatientProfilePage({
    Key? key,
    this.patientData,
    this.onEditProfile,
  }) : super(key: key);

  @override
  State<HumanPatientProfilePage> createState() => _HumanPatientProfilePageState();
}

class _HumanPatientProfilePageState extends State<HumanPatientProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection('humanpatients')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Profile not found');
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      print('Error fetching profile: $e');
      throw Exception('Error fetching profile: $e');
    }
  }

  void _handleEditProfile() {
    if (widget.onEditProfile != null) {
      widget.onEditProfile!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Profile not found',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to create profile page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No profile data found.'));
          }

          final patient = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.teal[100],
                        child: const Icon(Icons.person, size: 40, color: Colors.teal),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient['name'] ?? 'Not Set',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              patient['username'] ?? 'Not Set',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              patient['email'] ?? 'Not Set',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _handleEditProfile,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Personal Information
                _buildSection(
                  'Personal Information',
                  [
                    _buildInfoRow('Age', '${patient['age'] ?? 'Not Set'} years'),
                    _buildInfoRow('Gender', patient['sex'] ?? 'Not Set'),
                    _buildInfoRow('Blood Group', patient['bloodgroup'] ?? 'Not Set'),
                    _buildInfoRow('Phone Number', patient['phonenumber'] ?? 'Not Set'),
                    _buildInfoRow('Address', patient['address'] ?? 'Not Set'),
                    _buildInfoRow('Marital Status', patient['maritalStatus'] ?? 'Not Set'),
                    _buildInfoRow('Occupation', patient['occupation'] ?? 'Not Set'),
                    _buildInfoRow('Preferred Language', patient['preferredLanguage'] ?? 'Not Set'),
                  ],
                ),
                const SizedBox(height: 24),
                // Physical Information
                _buildSection(
                  'Physical Information',
                  [
                    _buildInfoRow('Height', '${patient['height'] ?? 'Not Set'} cm'),
                    _buildInfoRow('Weight', '${patient['weight'] ?? 'Not Set'} kg'),
                    _buildInfoRow('BMI', patient['bmi']?.toString() ?? 'Not Set'),
                    _buildInfoRow('Smoking Status', patient['smokingStatus'] ?? 'Not Set'),
                    _buildInfoRow('Dietary Restrictions', (patient['dietaryRestrictions'] as List?)?.join(', ') ?? 'None'),
                  ],
                ),
                const SizedBox(height: 24),
                // Medical Information
                _buildSection(
                  'Medical Information',
                  [
                    _buildInfoRow('Emergency Contact', patient['emergencyContact'] ?? 'Not Set'),
                    _buildInfoRow('Allergies', (patient['allergies'] as List?)?.join(', ') ?? 'None'),
                    _buildInfoRow('Medical History', patient['medicalHistory'] ?? 'Not Set'),
                    _buildInfoRow('Current Medications', patient['currentMedications'] ?? 'None'),
                  ],
                ),
                const SizedBox(height: 24),
                // Bio
                _buildSection(
                  'About',
                  [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        patient['bio'] ?? 'No bio available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 