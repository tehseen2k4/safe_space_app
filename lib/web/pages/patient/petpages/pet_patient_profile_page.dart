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
      return const Center(child: Text('No profile data found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
              children: [
                CircleAvatar(
                  radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.pets, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                              _profileData!['name'] ?? 'Pet Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                              _profileData!['species'] ?? 'Species',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                          ],
                  ),
                ),
                ElevatedButton.icon(
                        onPressed: widget.onEditProfile,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
                  const SizedBox(height: 32),
                  _buildInfoSection(
                    title: 'Pet Information',
                    items: [
                      _buildInfoItem('Species', _profileData!['species'] ?? 'Not specified'),
                      _buildInfoItem('Breed', _profileData!['breed'] ?? 'Not specified'),
                      _buildInfoItem('Age', '${_profileData!['age'] ?? 'Not specified'} years'),
                      _buildInfoItem('Weight', '${_profileData!['weight'] ?? 'Not specified'} kg'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
        ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 