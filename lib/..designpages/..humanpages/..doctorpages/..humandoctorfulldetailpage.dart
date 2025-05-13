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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Doctor Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isDesktop ? 28 : 24,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: true,
        toolbarHeight: isDesktop ? 80 : 70,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
          ),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .doc(widget.doctor['uid'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Text(
                    'No slots available.',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 16,
                      color: const Color(0xFF666666),
                    ),
                  ),
                );
              }

              final slots = snapshot.data!['slots'] ?? {};
              return SingleChildScrollView(
                padding: EdgeInsets.all(isDesktop ? 24 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(isDesktop),
                    SizedBox(height: isDesktop ? 24 : 16.0),
                    _buildSectionTitle('Personal Details', isDesktop),
                    _buildDetailCard([
                      _buildDetailRow('Username', widget.doctor['username'], isDesktop),
                      _buildDetailRow('Specialization', widget.doctor['specialization'], isDesktop),
                      _buildDetailRow('Qualification', widget.doctor['qualification'], isDesktop),
                      _buildDetailRow('Bio', widget.doctor['bio'], isDesktop),
                      _buildDetailRow('Email', widget.doctor['email'], isDesktop),
                      _buildDetailRow('Age', widget.doctor['age']?.toString(), isDesktop),
                      _buildDetailRow('Sex', widget.doctor['sex'], isDesktop),
                    ], isDesktop),
                    SizedBox(height: isDesktop ? 24 : 16.0),
                    _buildSectionTitle('Availability', isDesktop),
                    _buildDetailCard([
                      _buildDetailRow('Available Days', widget.doctor['availableDays']?.join(', '), isDesktop),
                      _buildDetailRow('Start Time', widget.doctor['startTime'], isDesktop),
                      _buildDetailRow('End Time', widget.doctor['endTime'], isDesktop),
                    ], isDesktop),
                    SizedBox(height: isDesktop ? 24 : 16.0),
                    _buildSectionTitle('Contact Information', isDesktop),
                    _buildDetailCard([
                      _buildDetailRow('Phone', widget.doctor['phone'], isDesktop),
                      _buildDetailRow('Address', widget.doctor['address'], isDesktop),
                    ], isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement booking functionality
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 48 : 32,
                            vertical: isDesktop ? 20 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children, bool isDesktop) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 12 : 8.0)),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 20 : 12.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, bool isDesktop) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Text(
                value ?? 'Not Available',
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        Divider(color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildHeaderSection(bool isDesktop) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isDesktop ? 16 : 10.0)),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: isDesktop ? 50.0 : 40.0,
              backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
              child: Text(
                widget.doctor['name']?.substring(0, 1).toUpperCase() ?? 'D',
                style: TextStyle(
                  fontSize: isDesktop ? 40.0 : 32.0,
                  color: const Color(0xFF1976D2),
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 24 : 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor['name'] ?? 'Doctor Name',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12 : 8.0),
                  Text(
                    widget.doctor['specialization'] ?? 'Specialization',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 18,
                      color: const Color(0xFF666666),
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

  Widget _buildSectionTitle(String title, bool isDesktop) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isDesktop ? 24 : 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1976D2),
      ),
    );
  }
}
