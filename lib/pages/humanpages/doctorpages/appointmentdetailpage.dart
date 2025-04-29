import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart'; // Import the model
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentDetailsPage extends StatefulWidget {
  final HumanAppointmentDb appointment;

  const AppointmentDetailsPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentDetailsPage> createState() => _AppointmentDetailsPageState();
}

class _AppointmentDetailsPageState extends State<AppointmentDetailsPage> {
  late TextEditingController _notesController;
  late TextEditingController _suggestedTimeController;
  late HumanAppointmentDb _appointment;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _notesController = TextEditingController(text: _appointment.doctorNotes ?? '');
    _suggestedTimeController = TextEditingController(text: _appointment.suggestedTimeslot ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _suggestedTimeController.dispose();
    super.dispose();
  }

  Future<void> _updateAppointmentStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('humanappointments')
          .doc(_appointment.appointmentId)
          .update({
        'responseStatus': status,
        'responseTimestamp': FieldValue.serverTimestamp(),
        'doctorNotes': _notesController.text,
        'suggestedTimeslot': _suggestedTimeController.text,
      });

      setState(() {
        _appointment.responseStatus = status;
        _appointment.responseTimestamp = DateTime.now();
        _appointment.doctorNotes = _notesController.text;
        _appointment.suggestedTimeslot = _suggestedTimeController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment $status successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating appointment: $e')),
      );
    }
  }

  void _showSuggestTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suggest Alternative Time'),
        content: TextField(
          controller: _suggestedTimeController,
          decoration: InputDecoration(
            hintText: 'Enter suggested time (e.g., Monday 2:00 PM)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAppointmentStatus('rejected');
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

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
            // Status Card
            Card(
              color: _getStatusColor(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Status: ${(_appointment.responseStatus ?? 'pending').toUpperCase()}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Existing details
            _buildDetailCard(
              'Appointment ID:',
              _appointment.appointmentId,
              Icons.assignment,
            ),
            _buildDetailCard(
              'Patient Name:',
              _appointment.username,
              Icons.person,
            ),
            _buildDetailCard(
              'Email:',
              _appointment.email,
              Icons.email,
            ),
            _buildDetailCard(
              'Phone Number:',
              _appointment.phonenumber,
              Icons.phone,
            ),
            _buildDetailCard(
              'Gender:',
              _appointment.gender,
              Icons.accessibility,
            ),
            _buildDetailCard(
              'Age:',
              _appointment.age,
              Icons.calendar_today,
            ),
            _buildDetailCard(
              'Reason for Visit:',
              _appointment.reasonforvisit,
              Icons.medical_services,
            ),
            _buildDetailCard(
              'Type of Appointment:',
              _appointment.typeofappointment,
              Icons.access_alarm,
            ),
            _buildDetailCard(
              'Doctor Preference:',
              _appointment.doctorpreference,
              Icons.favorite,
            ),
            _buildDetailCard(
              'Urgency Level:',
              _appointment.urgencylevel,
              Icons.warning_amber_rounded,
            ),
            _buildDetailCard(
              'Timeslot:',
              _appointment.timeslot,
              Icons.access_time,
            ),
            // Doctor's Notes
            Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor\'s Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter your notes here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Response Buttons
            if ((_appointment.responseStatus ?? 'pending') == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _updateAppointmentStatus('accepted'),
                    icon: Icon(Icons.check),
                    label: Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showSuggestTimeDialog,
                    icon: Icon(Icons.close),
                    label: Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                  ),
                ],
              ),
            // Show suggested time if rejected
            if ((_appointment.responseStatus ?? 'pending') == 'rejected' && (_appointment.suggestedTimeslot ?? '').isNotEmpty)
              _buildDetailCard(
                'Suggested Alternative Time:',
                _appointment.suggestedTimeslot ?? '',
                Icons.access_time,
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch ((_appointment.responseStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

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
