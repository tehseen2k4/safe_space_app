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
  String? _currentResponseStatus;
  String? _currentDoctorNotes;
  String? _currentSuggestedTime;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _currentResponseStatus = _appointment.responseStatus;
    _currentDoctorNotes = _appointment.doctorNotes;
    _currentSuggestedTime = _appointment.suggestedTimeslot;
    _notesController = TextEditingController(text: _currentDoctorNotes ?? '');
    _suggestedTimeController = TextEditingController(text: _currentSuggestedTime ?? '');
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
          .collection('appointments')
          .doc(_appointment.appointmentId)
          .update({
        'responseStatus': status,
        'responseTimestamp': FieldValue.serverTimestamp(),
        'doctorNotes': _notesController.text,
        'suggestedTimeslot': _suggestedTimeController.text,
      });

      setState(() {
        _currentResponseStatus = status;
        _currentDoctorNotes = _notesController.text;
        _currentSuggestedTime = _suggestedTimeController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment $status successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating appointment: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuggestTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Suggest Alternative Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _suggestedTimeController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Enter suggested time (e.g., Monday 2:00 PM)',
            hintStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAppointmentStatus('rejected');
            },
            child: const Text('Submit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Patient Information'),
              _buildInfoCard(
                [
                  _buildInfoRow('Name', _appointment.username, Icons.person),
                  _buildInfoRow('Email', _appointment.email, Icons.email),
                  _buildInfoRow('Phone', _appointment.phonenumber, Icons.phone),
                  _buildInfoRow('Gender', _appointment.gender, Icons.accessibility),
                  _buildInfoRow('Age', _appointment.age, Icons.calendar_today),
                ],
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Appointment Details'),
              _buildInfoCard(
                [
                  _buildInfoRow('Reason', _appointment.reasonforvisit, Icons.medical_services),
                  _buildInfoRow('Type', _appointment.typeofappointment, Icons.access_alarm),
                  _buildInfoRow('Doctor Preference', _appointment.doctorpreference, Icons.favorite),
                  _buildInfoRow('Urgency', _appointment.urgencylevel, Icons.warning_amber_rounded),
                  _buildInfoRow('Timeslot', _appointment.timeslot, Icons.access_time),
                ],
              ),
              const SizedBox(height: 16),

              _buildSectionTitle('Doctor\'s Notes'),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your notes here...',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if ((_currentResponseStatus ?? 'pending') == 'rejected' && 
                  (_currentSuggestedTime ?? '').isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSectionTitle('Suggested Alternative Time'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.teal, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              _currentSuggestedTime ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              if ((_currentResponseStatus ?? 'pending') == 'pending')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildResponseButton(
                        'Accept',
                        Icons.check,
                        Colors.green,
                        () => _updateAppointmentStatus('accepted'),
                      ),
                      _buildResponseButton(
                        'Reject',
                        Icons.close,
                        Colors.red,
                        _showSuggestTimeDialog,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${(_currentResponseStatus ?? 'pending').toUpperCase()}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }

  Color _getStatusColor() {
    switch ((_currentResponseStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch ((_currentResponseStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}
