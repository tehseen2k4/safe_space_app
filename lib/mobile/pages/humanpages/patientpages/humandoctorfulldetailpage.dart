import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _DoctorDetailPageState createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late Future<Map<String, dynamic>?> doctorSlots;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    doctorSlots = fetchDoctorSlots(widget.doctor['uid']);
  }

  Future<Map<String, dynamic>?> fetchDoctorSlots(String doctorId) async {
    try {
      final docSnapshot =
          await _firestore.collection('slots').doc(doctorId).get();
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

  // Display doctor slots with booking status
  Widget buildSlotList(Map<String, dynamic> slots) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: slots.entries.map((entry) {
            final day = entry.key;
            final slotList = entry.value as List<dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 12),
                ...slotList.map((slot) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('hh:mm a').format(DateTime.parse(slot['time'])),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: slot['booked']
                                ? Colors.red[50]
                                : Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slot['booked'] ? 'Booked' : 'Available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: slot['booked']
                                  ? Colors.red[700]
                                  : Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: doctorSlots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching doctor slots',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No slots available.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                const SizedBox(height: 24),
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
                const SizedBox(height: 24),
                _buildSectionTitle('Availability'),
                _buildAvailabilityCard(),
                const SizedBox(height: 24),
                _buildSectionTitle('Contact Information'),
                _buildDetailCard([
                  _buildDetailRow('Phone Number', widget.doctor['phonenumber']),
                  _buildDetailRow('Clinic Name', widget.doctor['clinicName']),
                  _buildDetailRow('Clinic Contact Number', widget.doctor['contactNumberClinic']),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('Professional Details'),
                _buildDetailCard([
                  _buildDetailRow('Fees', widget.doctor['fees']?.toString()),
                  _buildDetailRow('Doctor Type', widget.doctor['doctorType']),
                  _buildDetailRow('Experience', widget.doctor['experience']),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('Available Slots'),
                buildSlotList(slots),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
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
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Text(
                widget.doctor['name']?.substring(0, 1).toUpperCase() ?? 'D',
                style: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
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

  Widget _buildAvailabilityCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Start Time', widget.doctor['startTime']),
            _buildDetailRow('End Time', widget.doctor['endTime']),
            const SizedBox(height: 12),
            const Text(
              'Available Days',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (widget.doctor['availableDays'] as List<dynamic>? ?? [])
                  .map((day) => Chip(
                        label: Text(
                          day.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                        backgroundColor: Colors.teal[100],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Handle book appointment
          },
          icon: const Icon(Icons.calendar_today),
          label: const Text('Book Appointment'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Handle view reviews
          },
          icon: const Icon(Icons.rate_review),
          label: const Text('View Reviews'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
