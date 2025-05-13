import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetProfilePage extends StatefulWidget {
  final Map<String, dynamic>? petData;

  const PetProfilePage({
    Key? key,
    this.petData,
  }) : super(key: key);

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _petData;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    try {
      if (widget.petData != null) {
        setState(() {
          _petData = widget.petData;
          _isLoading = false;
        });
        return;
      }

      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('pets').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _petData = doc.data();
            _isLoading = false;
          });
        } else {
          // If no Firebase data, use dummy data
          setState(() {
            _petData = {
              'name': 'Buddy',
              'type': 'Dog',
              'breed': 'Golden Retriever',
              'age': '3',
              'sex': 'Male',
              'weight': '25 kg',
              'ownerName': 'John Doe',
              'ownerPhone': '+1 234 567 8900',
              'medicalHistory': 'No significant medical history',
              'lastCheckup': '2024-02-15',
              'vaccinations': 'Up to date',
              'allergies': 'None',
              'specialNeeds': 'None',
              'microchipNumber': '123456789',
              'registrationNumber': 'PET123456',
              'dietaryRequirements': 'Regular dog food, twice daily',
              'exerciseRoutine': 'Daily walks, 30 minutes',
              'groomingNeeds': 'Regular brushing, monthly bath',
              'behavioralNotes': 'Friendly, good with children',
              'insuranceProvider': 'PetCare Insurance',
              'insuranceNumber': 'PCI123456',
              'emergencyContact': 'Dr. Sarah Johnson, +1 234 567 8901',
              'preferredVet': 'Dr. Michael Chen',
              'preferredClinic': 'Paws & Care Veterinary Clinic',
              'lastVaccinationDate': '2024-01-15',
              'nextVaccinationDue': '2024-07-15',
              'spayedNeutered': 'Yes',
              'dateOfBirth': '2021-03-15',
              'adoptionDate': '2021-05-01',
              'previousOwner': 'None',
              'trainingStatus': 'Basic obedience trained',
              'favoriteTreats': 'Dental chews, peanut butter',
              'favoriteToys': 'Tennis ball, rope toy',
              'sleepingHabits': 'Sleeps in crate, 8-10 hours daily',
              'socialization': 'Good with other dogs, regular playdates',
            };
            _isLoading = false;
          });
        }
      } else {
        // If no user, use dummy data
        setState(() {
          _petData = {
            'name': 'Buddy',
            'type': 'Dog',
            'breed': 'Golden Retriever',
            'age': '3',
            'sex': 'Male',
            'weight': '25 kg',
            'ownerName': 'John Doe',
            'ownerPhone': '+1 234 567 8900',
            'medicalHistory': 'No significant medical history',
            'lastCheckup': '2024-02-15',
            'vaccinations': 'Up to date',
            'allergies': 'None',
            'specialNeeds': 'None',
            'microchipNumber': '123456789',
            'registrationNumber': 'PET123456',
            'dietaryRequirements': 'Regular dog food, twice daily',
            'exerciseRoutine': 'Daily walks, 30 minutes',
            'groomingNeeds': 'Regular brushing, monthly bath',
            'behavioralNotes': 'Friendly, good with children',
            'insuranceProvider': 'PetCare Insurance',
            'insuranceNumber': 'PCI123456',
            'emergencyContact': 'Dr. Sarah Johnson, +1 234 567 8901',
            'preferredVet': 'Dr. Michael Chen',
            'preferredClinic': 'Paws & Care Veterinary Clinic',
            'lastVaccinationDate': '2024-01-15',
            'nextVaccinationDue': '2024-07-15',
            'spayedNeutered': 'Yes',
            'dateOfBirth': '2021-03-15',
            'adoptionDate': '2021-05-01',
            'previousOwner': 'None',
            'trainingStatus': 'Basic obedience trained',
            'favoriteTreats': 'Dental chews, peanut butter',
            'favoriteToys': 'Tennis ball, rope toy',
            'sleepingHabits': 'Sleeps in crate, 8-10 hours daily',
            'socialization': 'Good with other dogs, regular playdates',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading pet data: $e');
      // Add dummy data for testing
      setState(() {
        _petData = {
          'name': 'Buddy',
          'type': 'Dog',
          'breed': 'Golden Retriever',
          'age': '3',
          'sex': 'Male',
          'weight': '25 kg',
          'ownerName': 'John Doe',
          'ownerPhone': '+1 234 567 8900',
          'medicalHistory': 'No significant medical history',
          'lastCheckup': '2024-02-15',
          'vaccinations': 'Up to date',
          'allergies': 'None',
          'specialNeeds': 'None',
          'microchipNumber': '123456789',
          'registrationNumber': 'PET123456',
          'dietaryRequirements': 'Regular dog food, twice daily',
          'exerciseRoutine': 'Daily walks, 30 minutes',
          'groomingNeeds': 'Regular brushing, monthly bath',
          'behavioralNotes': 'Friendly, good with children',
          'insuranceProvider': 'PetCare Insurance',
          'insuranceNumber': 'PCI123456',
          'emergencyContact': 'Dr. Sarah Johnson, +1 234 567 8901',
          'preferredVet': 'Dr. Michael Chen',
          'preferredClinic': 'Paws & Care Veterinary Clinic',
          'lastVaccinationDate': '2024-01-15',
          'nextVaccinationDue': '2024-07-15',
          'spayedNeutered': 'Yes',
          'dateOfBirth': '2021-03-15',
          'adoptionDate': '2021-05-01',
          'previousOwner': 'None',
          'trainingStatus': 'Basic obedience trained',
          'favoriteTreats': 'Dental chews, peanut butter',
          'favoriteToys': 'Tennis ball, rope toy',
          'sleepingHabits': 'Sleeps in crate, 8-10 hours daily',
          'socialization': 'Good with other dogs, regular playdates',
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_petData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pet Profile not found',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to create pet profile page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Create Pet Profile',
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
                        _petData!['name'] ?? 'Pet Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_petData!['type']} - ${_petData!['breed']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Age: ${_petData!['age']} years',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement edit profile
                  },
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
              _buildInfoRow('Type', _petData!['type'] ?? 'N/A'),
              _buildInfoRow('Breed', _petData!['breed'] ?? 'N/A'),
              _buildInfoRow('Age', '${_petData!['age']} years'),
              _buildInfoRow('Sex', _petData!['sex'] ?? 'N/A'),
              _buildInfoRow('Weight', _petData!['weight'] ?? 'N/A'),
              _buildInfoRow('Date of Birth', _petData!['dateOfBirth'] ?? 'N/A'),
              _buildInfoRow('Adoption Date', _petData!['adoptionDate'] ?? 'N/A'),
              _buildInfoRow('Spayed/Neutered', _petData!['spayedNeutered'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Owner Information
          _buildSection(
            'Owner Information',
            [
              _buildInfoRow('Owner Name', _petData!['ownerName'] ?? 'N/A'),
              _buildInfoRow('Owner Phone', _petData!['ownerPhone'] ?? 'N/A'),
              _buildInfoRow('Emergency Contact', _petData!['emergencyContact'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Medical Information
          _buildSection(
            'Medical Information',
            [
              _buildInfoRow('Medical History', _petData!['medicalHistory'] ?? 'N/A'),
              _buildInfoRow('Allergies', _petData!['allergies'] ?? 'N/A'),
              _buildInfoRow('Special Needs', _petData!['specialNeeds'] ?? 'N/A'),
              _buildInfoRow('Last Checkup', _petData!['lastCheckup'] ?? 'N/A'),
              _buildInfoRow('Last Vaccination', _petData!['lastVaccinationDate'] ?? 'N/A'),
              _buildInfoRow('Next Vaccination Due', _petData!['nextVaccinationDue'] ?? 'N/A'),
              _buildInfoRow('Microchip Number', _petData!['microchipNumber'] ?? 'N/A'),
              _buildInfoRow('Registration Number', _petData!['registrationNumber'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Care Information
          _buildSection(
            'Care Information',
            [
              _buildInfoRow('Dietary Requirements', _petData!['dietaryRequirements'] ?? 'N/A'),
              _buildInfoRow('Exercise Routine', _petData!['exerciseRoutine'] ?? 'N/A'),
              _buildInfoRow('Grooming Needs', _petData!['groomingNeeds'] ?? 'N/A'),
              _buildInfoRow('Sleeping Habits', _petData!['sleepingHabits'] ?? 'N/A'),
              _buildInfoRow('Training Status', _petData!['trainingStatus'] ?? 'N/A'),
              _buildInfoRow('Behavioral Notes', _petData!['behavioralNotes'] ?? 'N/A'),
              _buildInfoRow('Socialization', _petData!['socialization'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Preferences
          _buildSection(
            'Preferences',
            [
              _buildInfoRow('Favorite Treats', _petData!['favoriteTreats'] ?? 'N/A'),
              _buildInfoRow('Favorite Toys', _petData!['favoriteToys'] ?? 'N/A'),
              _buildInfoRow('Preferred Vet', _petData!['preferredVet'] ?? 'N/A'),
              _buildInfoRow('Preferred Clinic', _petData!['preferredClinic'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Insurance Information
          _buildSection(
            'Insurance Information',
            [
              _buildInfoRow('Insurance Provider', _petData!['insuranceProvider'] ?? 'N/A'),
              _buildInfoRow('Insurance Number', _petData!['insuranceNumber'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Appointments
          _buildSection(
            'Recent Appointments',
            [
              _buildAppointmentCard(
                'Dr. Sarah Johnson',
                'Regular Checkup',
                '2024-03-20',
                '10:00 AM',
                'Upcoming',
              ),
              _buildAppointmentCard(
                'Dr. Michael Chen',
                'Vaccination',
                '2024-03-22',
                '2:30 PM',
                'Confirmed',
              ),
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

  Widget _buildAppointmentCard(
    String doctorName,
    String reason,
    String date,
    String time,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: const Icon(Icons.pets, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      reason,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'Upcoming' ? Colors.orange[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Upcoming' ? Colors.orange[800] : Colors.green[800],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 