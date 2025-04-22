import 'package:flutter/material.dart';
import 'package:safe_space/models/humanappointment_db.dart';
import 'package:safe_space/pages/patientpages/appointmentdetailpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space/pages/patientpages/appointmentbooking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: FutureBuilder<List<HumanAppointmentDb>>(
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
              builder: (context) => BookAppointmentPage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<List<HumanAppointmentDb>> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => HumanAppointmentDb.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  Widget _buildCard(HumanAppointmentDb appointment, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 200,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 2, 93, 98),
            const Color.fromARGB(255, 177, 181, 181)
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
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                Text(
                  appointment.appointmentId,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(221, 255, 255, 255),
                  ),
                ),
              ],
            ),
            Divider(
                thickness: 1,
                color: const Color.fromARGB(255, 2, 93, 98),
                height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.person, color: Colors.white, size: 18),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.username,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.watch_later, color: Colors.white, size: 18),
                SizedBox(width: 5),
                Text(
                  appointment.timeslot,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(221, 255, 255, 255)),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.description, color: Colors.white, size: 18),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.reasonforvisit,
                    style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromRGBO(255, 255, 255, 1)),
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
                      builder: (context) => AppointmentDetailsPage(
                        appointment: appointment, // Pass appointment details
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 93, 98),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
