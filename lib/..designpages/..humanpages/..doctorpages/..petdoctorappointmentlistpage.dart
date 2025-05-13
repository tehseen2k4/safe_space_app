import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/petpages/petappointmentdetailpage.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        toolbarHeight: isDesktop ? 80 : 70,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
          ),
          child: FutureBuilder<List<PetAppointmentDb>>(
            future: _fetchAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error fetching appointments',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 16,
                      color: Colors.red,
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
                        size: isDesktop ? 80 : 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isDesktop ? 24 : 16),
                      Text(
                        'No appointments found',
                        style: TextStyle(
                          fontSize: isDesktop ? 24 : 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final appointments = snapshot.data!;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    children: appointments
                        .map((appointment) => _buildCard(appointment, context, isDesktop))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ),
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

  Widget _buildCard(PetAppointmentDb appointment, BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      height: isDesktop ? 250 : 200,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 20,
        vertical: isDesktop ? 16 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.teal.shade100, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment ID',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade700,
                  ),
                ),
                Text(
                  appointment.appointmentId,
                  style: TextStyle(
                    fontSize: isDesktop ? 14 : 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.teal.shade200, height: isDesktop ? 24 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.person,
                  color: Colors.teal,
                  size: isDesktop ? 22 : 18,
                ),
                SizedBox(width: isDesktop ? 8 : 5),
                Expanded(
                  child: Text(
                    appointment.username,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.watch_later,
                  color: Colors.teal,
                  size: isDesktop ? 22 : 18,
                ),
                SizedBox(width: isDesktop ? 8 : 5),
                Text(
                  appointment.timeslot,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Colors.teal,
                  size: isDesktop ? 22 : 18,
                ),
                SizedBox(width: isDesktop ? 8 : 5),
                Expanded(
                  child: Text(
                    appointment.reasonforvisit,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : 20,
                    vertical: isDesktop ? 16 : 10,
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
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
