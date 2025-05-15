import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/doctors_db.dart';
import 'package:safe_space_app/web/pages/doctor/edit_doctor_profile_page.dart';

class DoctorProfilePage extends StatefulWidget {
  final Map<String, dynamic>? doctorData;
  final VoidCallback? onEditProfile;

  const DoctorProfilePage({
    Key? key,
    this.doctorData,
    this.onEditProfile,
  }) : super(key: key);

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await _firestore
          .collection('doctors')
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

          final doctor = snapshot.data!;
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
                              'Dr. ${doctor['name'] ?? 'Not Set'}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              doctor['specialization'] ?? 'Not Set',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor['qualification'] ?? 'Not Set',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: widget.onEditProfile,
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
                    _buildInfoRow('Username', doctor['username'] ?? 'Not Set'),
                    _buildInfoRow('Email', doctor['email'] ?? 'Not Set'),
                    _buildInfoRow('Age', '${doctor['age'] ?? 'Not Set'} years'),
                    _buildInfoRow('Gender', doctor['sex'] ?? 'Not Set'),
                    _buildInfoRow('Phone Number', doctor['phonenumber'] ?? 'Not Set'),
                  ],
                ),
                const SizedBox(height: 24),
                // Professional Information
                _buildSection(
                  'Professional Information',
                  [
                    _buildInfoRow('Experience', doctor['experience'] ?? 'Not Set'),
                    _buildInfoRow('License Number', doctor['licenseNumber'] ?? 'Not Set'),
                    _buildInfoRow('Doctor Type', doctor['doctorType'] ?? 'Not Set'),
                    _buildInfoRow('Fees', '₹${doctor['fees'] ?? 'Not Set'}'),
                  ],
                ),
                const SizedBox(height: 24),
                // Clinic Information
                _buildSection(
                  'Clinic Information',
                  [
                    _buildInfoRow('Clinic Name', doctor['clinicName'] ?? 'Not Set'),
                    _buildInfoRow('Clinic Contact', doctor['contactNumberClinic'] ?? 'Not Set'),
                    if (doctor['availableDays'] != null && (doctor['availableDays'] as List).isNotEmpty)
                      _buildInfoRow('Available Days', (doctor['availableDays'] as List).join(', ')),
                    if (doctor['startTime'] != null && doctor['endTime'] != null)
                      _buildInfoRow('Working Hours', '${doctor['startTime']} - ${doctor['endTime']}'),
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
                        doctor['bio'] ?? 'No bio available',
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