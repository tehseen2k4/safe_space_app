import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  DoctorDetailPage({required this.doctor});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: slots.entries.map((entry) {
        final day = entry.key;
        final slotList = entry.value as List<dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...slotList.map((slot) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(DateTime.parse(slot['time'])),
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    slot['booked'] ? 'Booked' : 'Free',
                    style: TextStyle(
                      fontSize: 16,
                      color: slot['booked']
                          ? Colors.red
                          : const Color.fromARGB(255, 12, 133, 30),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
            SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doctor['name'] ?? 'Doctor Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: doctorSlots,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching doctor slots'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No slots available.'));
          }

          final slots = snapshot.data!['slots'] ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 16.0),
                _buildSectionTitle('Personal Details'),
                _buildDetailCard([
                  _buildDetailRow('Username', widget.doctor['username']),
                  _buildDetailRow(
                      'Specialization', widget.doctor['specialization']),
                  _buildDetailRow(
                      'Qualification', widget.doctor['qualification']),
                  _buildDetailRow('Bio', widget.doctor['bio']),
                  _buildDetailRow('Email', widget.doctor['email']),
                  _buildDetailRow('Age', widget.doctor['age']?.toString()),
                  _buildDetailRow('Sex', widget.doctor['sex']),
                ]),
                SizedBox(height: 16.0),
                _buildSectionTitle('Availability'),
                _buildDetailCard([
                  _buildDetailRow('Available Days',
                      widget.doctor['availableDays']?.join(', ')),
                  _buildDetailRow('Start Time', widget.doctor['startTime']),
                  _buildDetailRow('End Time', widget.doctor['endTime']),
                ]),
                SizedBox(height: 16.0),
                _buildSectionTitle('Contact Information'),
                _buildDetailCard([
                  _buildDetailRow('Phone Number', widget.doctor['phonenumber']),
                  _buildDetailRow('Clinic Name', widget.doctor['clinicName']),
                  _buildDetailRow('Clinic Contact Number',
                      widget.doctor['contactNumberClinic']),
                ]),
                SizedBox(height: 16.0),
                _buildSectionTitle('Professional Details'),
                _buildDetailCard([
                  _buildDetailRow('Fees', widget.doctor['fees']?.toString()),
                  _buildDetailRow('Doctor Type', widget.doctor['doctorType']),
                  _buildDetailRow('Experience', widget.doctor['experience']),
                ]),
                SizedBox(height: 16.0),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Text(
                value ?? 'Not Available',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40.0,
              backgroundColor: const Color.fromARGB(255, 172, 209, 200),
              child: Text(
                widget.doctor['name']?.substring(0, 1).toUpperCase() ?? 'D',
                style: TextStyle(
                  fontSize: 32.0,
                  color: const Color.fromARGB(255, 2, 93, 98),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor['name'] ?? 'Doctor Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    widget.doctor['specialization'] ?? 'Specialization',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }
}
