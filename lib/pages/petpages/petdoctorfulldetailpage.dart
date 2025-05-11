import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PetDoctorFullDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  PetDoctorFullDetailPage({required this.doctor});

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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        childAspectRatio: isDesktop ? 2.5 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final day = slots.keys.elementAt(index);
        final slotList = slots[day] as List<dynamic>;

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 2, 93, 98),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: slotList.length,
                    itemBuilder: (context, slotIndex) {
                      final slot = slotList[slotIndex];
                      final isBooked = slot['booked'] as bool;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isBooked ? Icons.lock : Icons.check_circle,
                          color: isBooked ? Colors.red : Colors.green,
                        ),
                        title: Text(
                          DateFormat('hh:mm a').format(DateTime.parse(slot['time'])),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Text(
                          isBooked ? 'Booked' : 'Free',
                          style: TextStyle(
                            fontSize: 16,
                            color: isBooked ? Colors.red : Colors.green,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.doctor['name'] ?? 'Doctor Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: doctorSlots,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching doctor slots'));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('No slots available.'));
            }

            final slots = snapshot.data!['slots'] ?? {};
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 16.0),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _buildSectionTitle('Availability'),
                              _buildDetailCard([
                                _buildDetailRow('Available Days', widget.doctor['availableDays']?.join(', ')),
                                _buildDetailRow('Start Time', widget.doctor['startTime']),
                                _buildDetailRow('End Time', widget.doctor['endTime']),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
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
                      ],
                    ),
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
              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
              child: Text(
                widget.doctor['name']?.substring(0, 1).toUpperCase() ?? 'D',
                style: TextStyle(
                  fontSize: 32.0,
                  color: Colors.white,
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
        color: const Color.fromARGB(255, 225, 118, 82),
      ),
    );
  }
}
