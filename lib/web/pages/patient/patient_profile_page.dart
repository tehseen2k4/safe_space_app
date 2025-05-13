import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/models/patients_db.dart';

class PatientProfilePage extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const PatientProfilePage({
    Key? key,
    this.patientData,
  }) : super(key: key);

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
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
        final doc = await _firestore.collection('humanpatients').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _patientData = doc.data();
            _isLoading = false;
          });
        } else {
          // If no Firebase data, use dummy data
          setState(() {
            _patientData = {
              'name': 'John Doe',
              'username': 'johndoe',
              'age': 28,
              'sex': 'Male',
              'email': 'john.doe@example.com',
              'bloodgroup': 'O+',
              'uid': 'dummy_uid',
              'phone': '+1 234 567 8900',
              'address': '123 Health Street',
              'emergencyContact': '+1 234 567 8901',
              'medicalHistory': 'No significant medical history',
              'allergies': 'None',
              'currentMedications': 'None',
              'lastCheckup': '2024-02-15',
              'bio': 'I am a health-conscious individual who believes in preventive healthcare. I regularly exercise and maintain a balanced diet. I have been managing my health conditions effectively with the help of my healthcare providers.',
              'insurance': 'Blue Cross Blue Shield',
              'insuranceNumber': 'BCBS123456789',
              'preferredLanguage': 'English',
              'maritalStatus': 'Single',
              'occupation': 'Software Engineer',
              'height': '175 cm',
              'weight': '70 kg',
              'bmi': '22.9',
              'smokingStatus': 'Never Smoked',
              'alcoholConsumption': 'Occasional',
              'exerciseFrequency': '3-4 times per week',
              'dietaryRestrictions': 'None',
              'familyHistory': 'Father: Hypertension, Mother: Type 2 Diabetes',
            };
            _isLoading = false;
          });
        }
      } else {
        // If no user, use dummy data
        setState(() {
          _patientData = {
            'name': 'John Doe',
            'username': 'johndoe',
            'age': 28,
            'sex': 'Male',
            'email': 'john.doe@example.com',
            'bloodgroup': 'O+',
            'uid': 'dummy_uid',
            'phone': '+1 234 567 8900',
            'address': '123 Health Street',
            'emergencyContact': '+1 234 567 8901',
            'medicalHistory': 'No significant medical history',
            'allergies': 'None',
            'currentMedications': 'None',
            'lastCheckup': '2024-02-15',
            'bio': 'I am a health-conscious individual who believes in preventive healthcare. I regularly exercise and maintain a balanced diet. I have been managing my health conditions effectively with the help of my healthcare providers.',
            'insurance': 'Blue Cross Blue Shield',
            'insuranceNumber': 'BCBS123456789',
            'preferredLanguage': 'English',
            'maritalStatus': 'Single',
            'occupation': 'Software Engineer',
            'height': '175 cm',
            'weight': '70 kg',
            'bmi': '22.9',
            'smokingStatus': 'Never Smoked',
            'alcoholConsumption': 'Occasional',
            'exerciseFrequency': '3-4 times per week',
            'dietaryRestrictions': 'None',
            'familyHistory': 'Father: Hypertension, Mother: Type 2 Diabetes',
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading patient data: $e');
      // Add dummy data for testing
      setState(() {
        _patientData = {
          'name': 'John Doe',
          'username': 'johndoe',
          'age': 28,
          'sex': 'Male',
          'email': 'john.doe@example.com',
          'bloodgroup': 'O+',
          'uid': 'dummy_uid',
          'phone': '+1 234 567 8900',
          'address': '123 Health Street',
          'emergencyContact': '+1 234 567 8901',
          'medicalHistory': 'No significant medical history',
          'allergies': 'None',
          'currentMedications': 'None',
          'lastCheckup': '2024-02-15',
          'bio': 'I am a health-conscious individual who believes in preventive healthcare. I regularly exercise and maintain a balanced diet. I have been managing my health conditions effectively with the help of my healthcare providers.',
          'insurance': 'Blue Cross Blue Shield',
          'insuranceNumber': 'BCBS123456789',
          'preferredLanguage': 'English',
          'maritalStatus': 'Single',
          'occupation': 'Software Engineer',
          'height': '175 cm',
          'weight': '70 kg',
          'bmi': '22.9',
          'smokingStatus': 'Never Smoked',
          'alcoholConsumption': 'Occasional',
          'exerciseFrequency': '3-4 times per week',
          'dietaryRestrictions': 'None',
          'familyHistory': 'Father: Hypertension, Mother: Type 2 Diabetes',
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
                  child: const Icon(Icons.person, size: 40, color: Colors.teal),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patientData!['name'] ?? 'Patient Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '@${_patientData!['username'] ?? 'username'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _patientData!['email'] ?? 'Email',
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
          // Personal Information
          _buildSection(
            'Personal Information',
            [
              _buildInfoRow('Age', '${_patientData!['age'] ?? 'N/A'} years'),
              _buildInfoRow('Gender', _patientData!['sex'] ?? 'N/A'),
              _buildInfoRow('Blood Group', _patientData!['bloodgroup'] ?? 'N/A'),
              _buildInfoRow('Phone', _patientData!['phone'] ?? 'N/A'),
              _buildInfoRow('Address', _patientData!['address'] ?? 'N/A'),
              _buildInfoRow('Marital Status', _patientData!['maritalStatus'] ?? 'N/A'),
              _buildInfoRow('Occupation', _patientData!['occupation'] ?? 'N/A'),
              _buildInfoRow('Preferred Language', _patientData!['preferredLanguage'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Physical Information
          _buildSection(
            'Physical Information',
            [
              _buildInfoRow('Height', _patientData!['height'] ?? 'N/A'),
              _buildInfoRow('Weight', _patientData!['weight'] ?? 'N/A'),
              _buildInfoRow('BMI', _patientData!['bmi'] ?? 'N/A'),
              _buildInfoRow('Smoking Status', _patientData!['smokingStatus'] ?? 'N/A'),
              _buildInfoRow('Alcohol Consumption', _patientData!['alcoholConsumption'] ?? 'N/A'),
              _buildInfoRow('Exercise Frequency', _patientData!['exerciseFrequency'] ?? 'N/A'),
              _buildInfoRow('Dietary Restrictions', _patientData!['dietaryRestrictions'] ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 24),
          // Medical Information
          _buildSection(
            'Medical Information',
            [
              _buildInfoRow('Emergency Contact', _patientData!['emergencyContact'] ?? 'N/A'),
              _buildInfoRow('Medical History', _patientData!['medicalHistory'] ?? 'N/A'),
              _buildInfoRow('Allergies', _patientData!['allergies'] ?? 'N/A'),
              _buildInfoRow('Current Medications', _patientData!['currentMedications'] ?? 'N/A'),
              _buildInfoRow('Last Checkup', _patientData!['lastCheckup'] ?? 'N/A'),
              _buildInfoRow('Family History', _patientData!['familyHistory'] ?? 'N/A'),
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
                'Cardiology',
                '2024-03-20',
                '10:00 AM',
                'Upcoming',
              ),
              _buildAppointmentCard(
                'Dr. Michael Chen',
                'Neurology',
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