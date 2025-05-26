import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/petpatient_db.dart';

class PetPatientProfilePage extends StatefulWidget {
  final VoidCallback? onEditProfile;

  const PetPatientProfilePage({
    Key? key,
    this.onEditProfile,
  }) : super(key: key);

  @override
  State<PetPatientProfilePage> createState() => _PetPatientProfilePageState();
}

class _PetPatientProfilePageState extends State<PetPatientProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('pets').doc(user.uid);
        final docSnapshot = await docRef.get();
        
        if (docSnapshot.exists) {
          setState(() {
            _profileData = docSnapshot.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _profileData = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_profileData == null) {
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
    }

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
                  child: const Icon(Icons.pets, size: 40, color: Colors.teal),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileData!['name'] ?? 'Not Set',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _profileData!['type'] ?? 'Not Set',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profileData!['email'] ?? 'Not Set',
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
          // Basic Information
          _buildSection(
            'Basic Information',
            [
              _buildInfoRow('Species', _profileData!['type'] ?? 'Not Set'),
              _buildInfoRow('Breed', _profileData!['breed'] ?? 'Not Set'),
              _buildInfoRow('Age', '${_profileData!['age'] ?? 'Not Set'} years'),
              _buildInfoRow('Gender', _profileData!['sex'] ?? 'Not Set'),
              _buildInfoRow('Date of Birth', _profileData!['dateOfBirth'] != null 
                ? (_profileData!['dateOfBirth'] as Timestamp).toDate().toString().split(' ')[0]
                : 'Not Set'),
              _buildInfoRow('Weight', '${_profileData!['weight'] ?? 'Not Set'} kg'),
              _buildInfoRow('Neuter Status', _profileData!['neuterStatus'] ?? 'Not Set'),
            ],
          ),
          const SizedBox(height: 24),
          // Owner Information
          _buildSection(
            'Owner Information',
            [
              _buildInfoRow('Owner Name', _profileData!['ownerName'] ?? 'Not Set'),
              _buildInfoRow('Owner Phone', _profileData!['ownerPhone'] ?? 'Not Set'),
              _buildInfoRow('Emergency Contact', _profileData!['emergencyContact'] ?? 'Not Set'),
            ],
          ),
          const SizedBox(height: 24),
          // Medical Information
          _buildSection(
            'Medical Information',
            [
              _buildInfoRow('Allergies', (_profileData!['allergies'] as List?)?.join(', ') ?? 'None'),
              _buildInfoRow('Special Needs', (_profileData!['specialNeeds'] as List?)?.join(', ') ?? 'None'),
              _buildInfoRow('Last Vaccination', _profileData!['lastVaccination'] != null 
                ? (_profileData!['lastVaccination'] as Timestamp).toDate().toString().split(' ')[0]
                : 'Not Set'),
              _buildInfoRow('Dietary Requirements', (_profileData!['dietaryRequirements'] as List?)?.join(', ') ?? 'None'),
            ],
          ),
          const SizedBox(height: 24),
          // Care Information
          _buildSection(
            'Care Information',
            [
              _buildInfoRow('Grooming Needs', (_profileData!['groomingNeeds'] as List?)?.join(', ') ?? 'None'),
              _buildInfoRow('Training Status', _profileData!['trainingStatus'] ?? 'Not Set'),
            ],
          ),
        ],
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