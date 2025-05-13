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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Suggest Alternative Time',
          style: TextStyle(fontSize: isDesktop ? 20 : 18),
        ),
        content: TextField(
          controller: _suggestedTimeController,
          style: TextStyle(fontSize: isDesktop ? 16 : 14),
          decoration: InputDecoration(
            hintText: 'Enter suggested time (e.g., Monday 2:00 PM)',
            hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAppointmentStatus('rejected');
            },
            child: Text(
              'Submit',
              style: TextStyle(fontSize: isDesktop ? 16 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 16,
                vertical: isDesktop ? 16 : 12,
              ),
            ),
          ),
        ],
      ),
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
          'Appointment Details',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        toolbarHeight: isDesktop ? 80 : 60,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
          ),
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
            padding: EdgeInsets.all(isDesktop ? 40 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(isDesktop),
                SizedBox(height: isDesktop ? 32 : 24),
                
                _buildSectionTitle('Patient Information', isDesktop),
                _buildInfoCard(
                  [
                    _buildInfoRow('Name', _appointment.username, Icons.person, isDesktop),
                    _buildInfoRow('Email', _appointment.email, Icons.email, isDesktop),
                    _buildInfoRow('Phone', _appointment.phonenumber, Icons.phone, isDesktop),
                    _buildInfoRow('Gender', _appointment.gender, Icons.accessibility, isDesktop),
                    _buildInfoRow('Age', _appointment.age, Icons.calendar_today, isDesktop),
                  ],
                  isDesktop,
                ),
                SizedBox(height: isDesktop ? 24 : 16),

                _buildSectionTitle('Appointment Details', isDesktop),
                _buildInfoCard(
                  [
                    _buildInfoRow('Reason', _appointment.reasonforvisit, Icons.medical_services, isDesktop),
                    _buildInfoRow('Type', _appointment.typeofappointment, Icons.access_alarm, isDesktop),
                    _buildInfoRow('Doctor Preference', _appointment.doctorpreference, Icons.favorite, isDesktop),
                    _buildInfoRow('Urgency', _appointment.urgencylevel, Icons.warning_amber_rounded, isDesktop),
                    _buildInfoRow('Timeslot', _appointment.timeslot, Icons.access_time, isDesktop),
                  ],
                  isDesktop,
                ),
                SizedBox(height: isDesktop ? 24 : 16),

                _buildSectionTitle('Doctor\'s Notes', isDesktop),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 24 : 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _notesController,
                          maxLines: 4,
                          style: TextStyle(fontSize: isDesktop ? 16 : 14),
                          decoration: InputDecoration(
                            hintText: 'Enter your notes here...',
                            hintStyle: TextStyle(fontSize: isDesktop ? 14 : 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.all(isDesktop ? 20 : 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if ((_appointment.responseStatus ?? 'pending') == 'rejected' && 
                    (_appointment.suggestedTimeslot ?? '').isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isDesktop ? 24 : 16),
                      _buildSectionTitle('Suggested Alternative Time', isDesktop),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop ? 24 : 16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.teal,
                                size: isDesktop ? 28 : 24,
                              ),
                              SizedBox(width: isDesktop ? 16 : 12),
                              Text(
                                _appointment.suggestedTimeslot ?? '',
                                style: TextStyle(
                                  fontSize: isDesktop ? 18 : 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                if ((_appointment.responseStatus ?? 'pending') == 'pending')
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: isDesktop ? 32 : 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResponseButton(
                          'Accept',
                          Icons.check,
                          Colors.green,
                          () => _updateAppointmentStatus('accepted'),
                          isDesktop,
                        ),
                        _buildResponseButton(
                          'Reject',
                          Icons.close,
                          Colors.red,
                          _showSuggestTimeDialog,
                          isDesktop,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 24 : 16,
        horizontal: isDesktop ? 32 : 24,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            color: Colors.white,
            size: isDesktop ? 40 : 32,
          ),
          SizedBox(height: isDesktop ? 12 : 8),
          Text(
            'Status: ${(_appointment.responseStatus ?? 'pending').toUpperCase()}',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isDesktop ? 22 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children, bool isDesktop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.teal,
            size: isDesktop ? 24 : 20,
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: isDesktop ? 6 : 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
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
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isDesktop,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: isDesktop ? 24 : 20,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isDesktop ? 18 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 32,
          vertical: isDesktop ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
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

  IconData _getStatusIcon() {
    switch ((_appointment.responseStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
}
