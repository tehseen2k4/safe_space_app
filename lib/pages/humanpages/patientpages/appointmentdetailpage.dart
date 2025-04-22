import 'package:flutter/material.dart';
import 'package:safe_space/models/humanappointment_db.dart'; // Import the model

class AppointmentDetailsPage extends StatelessWidget {
  final HumanAppointmentDb appointment;

  // Constructor to receive the appointment details
  const AppointmentDetailsPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard(
              'Appointment ID:',
              appointment.appointmentId,
              Icons.assignment,
            ),
            _buildDetailCard(
              'Patient Name:',
              appointment.username,
              Icons.person,
            ),
            _buildDetailCard(
              'Email:',
              appointment.email,
              Icons.email,
            ),
            _buildDetailCard(
              'Phone Number:',
              appointment.phonenumber,
              Icons.phone,
            ),
            _buildDetailCard(
              'Gender:',
              appointment.gender,
              Icons.accessibility,
            ),
            _buildDetailCard(
              'Age:',
              appointment.age,
              Icons.calendar_today,
            ),
            _buildDetailCard(
              'Reason for Visit:',
              appointment.reasonforvisit,
              Icons.medical_services,
            ),
            _buildDetailCard(
              'Type of Appointment:',
              appointment.typeofappointment,
              Icons.access_alarm,
            ),
            _buildDetailCard(
              'Doctor Preference:',
              appointment.doctorpreference,
              Icons.favorite,
            ),
            _buildDetailCard(
              'Urgency Level:',
              appointment.urgencylevel,
              Icons.warning_amber_rounded,
            ),
            _buildDetailCard(
              'Timeslot:',
              appointment.timeslot,
              Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to create the label and value rows in a card format
  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
