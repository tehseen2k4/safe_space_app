import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/patients_db.dart';

class PetPatientProfilePage extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const PetPatientProfilePage({
    Key? key,
    this.patientData,
  }) : super(key: key);

  @override
  State<PetPatientProfilePage> createState() => _PetPatientProfilePageState();
}

class _PetPatientProfilePageState extends State<PetPatientProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    try {
      if (widget.patientData != null) {
        setState(() {
          _patientData = widget.patientData;
          _isLoading = false;
        });
        return;
      }

      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('petpatients').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _patientData = doc.data();
            _isLoading = false;
          });
        } else {
          // If no Firebase data, use dummy data
          setState(() {
            _patientData = {
              'name': 'Max',
              'species': 'Dog',
              'breed': 'Golden Retriever',
              'age': 3,
              'gender': 'Male',
              'ownerName': 'John Doe',
              'ownerEmail': 'john.doe@example.com',
              'ownerPhone': '+1 234 567 8900',
              'weight': '25 kg',
              'microchipNumber': '123456789',
              'lastVaccination': '2024-01-15',
              'medicalHistory': 'No significant medical history',
              'allergies': 'None',
              'currentMedications': 'None',
              'lastCheckup': '2024-02-15',
              'bio': 'Friendly and active dog who loves playing fetch and going for walks. Regular checkups and vaccinations are up to date.',
              'insurance': 'PetCare Insurance',
              'insuranceNumber': 'PCI123456789',
              'feedingSchedule': 'Twice daily',
              'exerciseRoutine': 'Daily walks and playtime',
              'groomingNeeds': 'Regular brushing and monthly baths',
              'behavioralNotes': 'Well-behaved, good with children and other pets',
              'specialCare': 'None',
              'veterinarian': 'Dr. Sarah Johnson',
              'clinic': 'Paws & Care Veterinary Clinic',
            };
            _isLoading = false;
          });
        }
      } else {
        // If no user, use dummy data
        setState(() {
          _patientData = {
            'name': 'Max',
            'species': 'Dog',
            'breed': 'Golden Retriever',
            'age': 3,
            'gender': 'Male',
            'ownerName': 'John Doe',
            'ownerEmail': 'john.doe@example.com',
            'ownerPhone': '+1 234 567 8900',
            'weight': '25 kg',
            'microchipNumber': '123456789',
            'lastVaccination': '2024-01-15',
            'medicalHistory': 'No significant medical history',
            'allergies': 'None',
            'currentMedications': 'None',
            'lastCheckup': '2024-02-15',
            'bio': 'Friendly and active dog who loves playing fetch and going for walks. Regular checkups and vaccinations are up to date.',
            'insurance': 'PetCare Insurance',
            'insuranceNumber': 'PCI123456789',
            'feedingSchedule': 'Twice daily',
            'exerciseRoutine': 'Daily walks and playtime',
            'groomingNeeds': 'Regular brushing and monthly baths',
            'behavioralNotes': 'Well-behaved, good with children and other pets',
            'specialCare': 'None',
            'veterinarian': 'Dr. Sarah Johnson',
            'clinic': 'Paws & Care Veterinary Clinic',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading patient data: $e');
      setState(() {
        _patientData = {
          'name': 'Max',
          'species': 'Dog',
          'breed': 'Golden Retriever',
          'age': 3,
          'gender': 'Male',
          'ownerName': 'John Doe',
          'ownerEmail': 'john.doe@example.com',
          'ownerPhone': '+1 234 567 8900',
          'weight': '25 kg',
          'microchipNumber': '123456789',
          'lastVaccination': '2024-01-15',
          'medicalHistory': 'No significant medical history',
          'allergies': 'None',
          'currentMedications': 'None',
          'lastCheckup': '2024-02-15',
          'bio': 'Friendly and active dog who loves playing fetch and going for walks. Regular checkups and vaccinations are up to date.',
          'insurance': 'PetCare Insurance',
          'insuranceNumber': 'PCI123456789',
          'feedingSchedule': 'Twice daily',
          'exerciseRoutine': 'Daily walks and playtime',
          'groomingNeeds': 'Regular brushing and monthly baths',
          'behavioralNotes': 'Well-behaved, good with children and other pets',
          'specialCare': 'None',
          'veterinarian': 'Dr. Sarah Johnson',
          'clinic': 'Paws & Care Veterinary Clinic',
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

    if (_patientData == null) {
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
                        _patientData!['name'] ?? 'Pet Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_patientData!['species']} - ${_patientData!['breed']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Owner: ${_patientData!['ownerName']}',
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
          // Pet Information
          _buildSection(
            'Pet Information',
            [
              _buildInfoRow('Species', _patientData!['species'] ?? 'N/A'),
              _buildInfoRow('Breed', _patientData!['breed'] ?? 'N/A'),
              _buildInfoRow('Age', '${_patientData!['age'] ?? 'N/A'} years'),
              _buildInfoRow('Gender', _patientData!['gender'] ?? 'N/A'),
              _buildInfoRow('Weight', _patientData!['weight'] ?? 'N/A'),
              _buildInfoRow('Microchip Number', _patientData!['microchipNumber'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Owner Information
          _buildSection(
            'Owner Information',
            [
              _buildInfoRow('Owner Name', _patientData!['ownerName'] ?? 'N/A'),
              _buildInfoRow('Owner Email', _patientData!['ownerEmail'] ?? 'N/A'),
              _buildInfoRow('Owner Phone', _patientData!['ownerPhone'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Care Information
          _buildSection(
            'Care Information',
            [
              _buildInfoRow('Feeding Schedule', _patientData!['feedingSchedule'] ?? 'N/A'),
              _buildInfoRow('Exercise Routine', _patientData!['exerciseRoutine'] ?? 'N/A'),
              _buildInfoRow('Grooming Needs', _patientData!['groomingNeeds'] ?? 'N/A'),
              _buildInfoRow('Behavioral Notes', _patientData!['behavioralNotes'] ?? 'N/A'),
              _buildInfoRow('Special Care', _patientData!['specialCare'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Medical Information
          _buildSection(
            'Medical Information',
            [
              _buildInfoRow('Last Vaccination', _patientData!['lastVaccination'] ?? 'N/A'),
              _buildInfoRow('Medical History', _patientData!['medicalHistory'] ?? 'N/A'),
              _buildInfoRow('Allergies', _patientData!['allergies'] ?? 'N/A'),
              _buildInfoRow('Current Medications', _patientData!['currentMedications'] ?? 'N/A'),
              _buildInfoRow('Last Checkup', _patientData!['lastCheckup'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Insurance Information
          _buildSection(
            'Insurance Information',
            [
              _buildInfoRow('Insurance Provider', _patientData!['insurance'] ?? 'N/A'),
              _buildInfoRow('Insurance Number', _patientData!['insuranceNumber'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Veterinary Information
          _buildSection(
            'Veterinary Information',
            [
              _buildInfoRow('Primary Veterinarian', _patientData!['veterinarian'] ?? 'N/A'),
              _buildInfoRow('Clinic', _patientData!['clinic'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // About
          _buildSection(
            'About',
            [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _patientData!['bio'] ?? 'No bio available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Appointments
          _buildSection(
            'Recent Appointments',
            [
              _buildAppointmentCard(
                'Dr. Sarah Johnson',
                'Veterinary Checkup',
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
    String specialization,
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
                child: const Icon(Icons.person, color: Colors.teal),
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
                      specialization,
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