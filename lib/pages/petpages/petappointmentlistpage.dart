import 'package:flutter/material.dart';
import 'package:safe_space/models/petappointment_db.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:safe_space/pages/patientpages/petappointmentbooking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space/pages/patientpages/petappointmentdetailpage.dart';

class PetAppointmentsListPage extends StatefulWidget {
  @override
  _PetAppointmentsListPageState createState() =>
      _PetAppointmentsListPageState();
}

class _PetAppointmentsListPageState extends State<PetAppointmentsListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<PetAppointmentDb>>(
        future: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching appointments'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found'));
          }

          final appointments = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: appointments
                  .map((appointment) => _buildCard(appointment, context))
                  .toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookAppointmentPetPage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<List<PetAppointmentDb>> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('petappointments')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => PetAppointmentDb.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  Widget _buildCard(PetAppointmentDb appointment, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 225, 118, 82),
            const Color.fromARGB(128, 228, 211, 190)
          ],
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
        padding: EdgeInsets.all(15),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  appointment.appointmentId,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Divider(
                thickness: 1,
                color: const Color.fromARGB(255, 225, 118, 82),
                height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.person,
                    color: const Color.fromARGB(255, 255, 255, 255), size: 18),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.watch_later,
                    color: const Color.fromARGB(255, 255, 255, 255), size: 18),
                SizedBox(width: 5),
                Text(
                  appointment.timeslot,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(221, 255, 255, 255)),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.description,
                    color: const Color.fromARGB(255, 255, 255, 255), size: 18),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.reasonforvisit,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 255, 255, 255)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the AppointmentDetailsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetAppointmentDetailsPage(
                        appointment: appointment, // Pass appointment details
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
