import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetDoctorFullDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const PetDoctorFullDetailPage({required this.doctor});

  @override
  _PetDoctorFullDetailPageState createState() => _PetDoctorFullDetailPageState();
}

class _PetDoctorFullDetailPageState extends State<PetDoctorFullDetailPage> {
  late Future<Map<String, dynamic>?> doctorSlots;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    doctorSlots = fetchDoctorSlots(widget.doctor['uid']);
  }

  Future<Map<String, dynamic>?> fetchDoctorSlots(String doctorId) async {
    try {
      final docSnapshot = await _firestore.collection('slots').doc(doctorId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching slots for doctor: $e');
      return null;
    }
  }

  Widget buildSlotList(Map<String, dynamic> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slots.entries.map((entry) {
        final day = entry.key;
        final slotList = entry.value as List<dynamic>;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFFE17652),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE17652),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...slotList.map((slot) {
                  final isBooked = slot['booked'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isBooked ? Icons.lock : Icons.check_circle,
                              color: isBooked ? Colors.red : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('hh:mm a')
                                  .format(DateTime.parse(slot['time'])),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isBooked ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isBooked ? 'Booked' : 'Free',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          widget.doctor['name'] ?? 'Doctor Details',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE17652),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: doctorSlots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE17652),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error fetching doctor slots',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.pets,
                    color: Color(0xFFE17652),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No slots available.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final slots = snapshot.data!['slots'] ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 16.0),
                _buildSectionTitle('Personal Details'),
                _buildDetailCard([
                  _buildDetailRow('Username', widget.doctor['username']),
                  _buildDetailRow('Specialization', widget.doctor['specialization']),
                  _buildDetailRow('Qualification', widget.doctor['qualification']),
                  _buildDetailRow('Bio', widget.doctor['bio']),
                  _buildDetailRow('Email', widget.doctor['email']),
                  _buildDetailRow('Age', widget.doctor['age']?.toString()),
                  _buildDetailRow('Sex', widget.doctor['sex']),
                ]),
                const SizedBox(height: 16.0),
                _buildSectionTitle('Availability'),
                _buildDetailCard([
                  _buildDetailRow('Available Days', widget.doctor['availableDays']?.join(', ')),
                  _buildDetailRow('Start Time', widget.doctor['startTime']),
                  _buildDetailRow('End Time', widget.doctor['endTime']),
                ]),
                const SizedBox(height: 16.0),
                _buildSectionTitle('Contact Information'),
                _buildDetailCard([
                  _buildDetailRow('Phone Number', widget.doctor['phonenumber']),
                  _buildDetailRow('Clinic Name', widget.doctor['clinicName']),
                  _buildDetailRow('Clinic Contact Number', widget.doctor['contactNumberClinic']),
                ]),
                const SizedBox(height: 16.0),
                _buildSectionTitle('Professional Details'),
                _buildDetailCard([
                  _buildDetailRow('Fees', widget.doctor['fees']?.toString()),
                  _buildDetailRow('Doctor Type', widget.doctor['doctorType']),
                  _buildDetailRow('Experience', widget.doctor['experience']),
                ]),
                const SizedBox(height: 16.0),
                _buildSectionTitle('Available Slots'),
                buildSlotList(slots),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3142),
              ),
            ),
            Flexible(
              child: Text(
                value ?? 'Not Available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const Divider(color: Color(0xFFE0E0E0)),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: const Color(0xFFE17652).withOpacity(0.1),
              child: Text(
                widget.doctor['name']?.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(
                  fontSize: 32.0,
                  color: Color(0xFFE17652),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor['name'] ?? 'Doctor Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    widget.doctor['specialization'] ?? 'Specialization',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(
            _getSectionIcon(title),
            color: const Color(0xFFE17652),
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE17652),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String title) {
    switch (title) {
      case 'Personal Details':
        return Icons.person;
      case 'Availability':
        return Icons.calendar_today;
      case 'Contact Information':
        return Icons.contact_phone;
      case 'Professional Details':
        return Icons.work;
      case 'Available Slots':
        return Icons.access_time;
      default:
        return Icons.info;
    }
  }
}
