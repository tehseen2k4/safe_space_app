import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';

class PatientAppointmentDetailsPage extends StatelessWidget {
  final HumanAppointmentDb appointment;

  const PatientAppointmentDetailsPage({Key? key, required this.appointment})
      : super(key: key);

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
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1976D2).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1000 : (isTablet ? 800 : screenSize.width),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 20 : 16),
                vertical: isDesktop ? 40 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(isDesktop),
                  SizedBox(height: isDesktop ? 32 : 24),
                  
                  _buildSectionTitle('Patient Information', isDesktop),
                  _buildInfoCard(
                    [
                      _buildInfoRow('Name', appointment.username, Icons.person, isDesktop),
                      _buildInfoRow('Email', appointment.email, Icons.email, isDesktop),
                      _buildInfoRow('Phone', appointment.phonenumber, Icons.phone, isDesktop),
                      _buildInfoRow('Gender', appointment.gender, Icons.accessibility, isDesktop),
                      _buildInfoRow('Age', appointment.age, Icons.calendar_today, isDesktop),
                    ],
                    isDesktop,
                  ),
                  SizedBox(height: isDesktop ? 24 : 16),

                  _buildSectionTitle('Appointment Details', isDesktop),
                  _buildInfoCard(
                    [
                      _buildInfoRow('Reason', appointment.reasonforvisit, Icons.medical_services, isDesktop),
                      _buildInfoRow('Type', appointment.typeofappointment, Icons.access_alarm, isDesktop),
                      _buildInfoRow('Doctor Preference', appointment.doctorpreference, Icons.favorite, isDesktop),
                      _buildInfoRow('Urgency', appointment.urgencylevel, Icons.warning_amber_rounded, isDesktop),
                      _buildInfoRow('Timeslot', appointment.timeslot, Icons.access_time, isDesktop),
                    ],
                    isDesktop,
                  ),

                  if ((appointment.responseStatus ?? 'pending') == 'rejected' && 
                      (appointment.suggestedTimeslot ?? '').isNotEmpty)
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
                            padding: EdgeInsets.all(isDesktop ? 24 : 16),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, 
                                  color: Colors.teal,
                                  size: isDesktop ? 32 : 24,
                                ),
                                SizedBox(width: isDesktop ? 16 : 12),
                                Text(
                                  appointment.suggestedTimeslot ?? '',
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
                ],
              ),
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
            offset: const Offset(0, 4),
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
            'Status: ${(appointment.responseStatus ?? 'pending').toUpperCase()}',
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
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isDesktop ? 22 : 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1976D2),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> infoRows, bool isDesktop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          children: infoRows,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF1976D2),
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

  Color _getStatusColor() {
    switch ((appointment.responseStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch ((appointment.responseStatus ?? 'pending').toLowerCase()) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }
} 