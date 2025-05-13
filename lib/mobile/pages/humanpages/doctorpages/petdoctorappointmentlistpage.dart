import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/petpages/petappointmentdetailpage.dart';

class PetDoctorAppointmentsListPage extends StatefulWidget {
  @override
  _PetDoctorAppointmentsListPageState createState() =>
      _PetDoctorAppointmentsListPageState();
}

class _PetDoctorAppointmentsListPageState
    extends State<PetDoctorAppointmentsListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 70,
      ),
      body: FutureBuilder<List<PetAppointmentDb>>(
        future: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching appointments',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments found',
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

          final appointments = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: appointments
                    .map((appointment) => _buildCard(appointment, context))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<PetAppointmentDb>> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in');
      return [];
    }

    try {
      print('Fetching pet appointments for doctor: ${user.uid}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('petappointments')
          .where('doctorUid', isEqualTo: user.uid)
          .get();

      print('Query returned ${querySnapshot.docs.length} appointments');
      
      if (querySnapshot.docs.isEmpty) {
        print('No appointments found for this doctor');
        return [];
      }

      final appointments = querySnapshot.docs
          .map((doc) {
            print('Processing appointment: ${doc.id}');
            return PetAppointmentDb.fromJson(doc.data());
          })
          .toList();
      
      print('Successfully processed ${appointments.length} appointments');
      return appointments;
    } catch (e) {
      print("Error fetching pet appointments: $e");
      return [];
    }
  }

  Widget _buildCard(PetAppointmentDb appointment, BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.teal.shade100, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment ID',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  appointment.appointmentId,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1,
              color: Colors.teal.shade200,
              height: 20,
            ),
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Colors.teal,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.username,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.watch_later,
                  color: Colors.teal,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  appointment.timeslot,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.teal,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.reasonforvisit,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetAppointmentDetailsPage(
                        appointment: appointment,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
