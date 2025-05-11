import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petappointment_db.dart';

class PetAppointmentDetailsPage extends StatelessWidget {
  final PetAppointmentDb appointment;

  const PetAppointmentDetailsPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pet Appointment Details',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        elevation: 0,
      ),
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 225, 118, 82).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(context),
              SizedBox(height: isDesktop ? 32 : 24),
              
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'Pet Information'),
                          _buildInfoCard(
                            context,
                            [
                              _buildInfoRow(context, 'Pet Name', appointment.petname, Icons.pets),
                              _buildInfoRow(context, 'Email', appointment.email, Icons.email),
                              _buildInfoRow(context, 'Phone', appointment.phonenumber, Icons.phone),
                              _buildInfoRow(context, 'Pet Type', appointment.pettype, Icons.pets),
                              _buildInfoRow(context, 'Pet Breed', appointment.petbreed, Icons.pets),
                              _buildInfoRow(context, 'Pet Age', appointment.petage, Icons.calendar_today),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'Appointment Details'),
                          _buildInfoCard(
                            context,
                            [
                              _buildInfoRow(context, 'Reason', appointment.reasonforvisit, Icons.medical_services),
                              _buildInfoRow(context, 'Type', appointment.typeofappointment, Icons.access_alarm),
                              _buildInfoRow(context, 'Doctor Preference', appointment.doctorpreference, Icons.favorite),
                              _buildInfoRow(context, 'Urgency', appointment.urgencylevel, Icons.warning_amber_rounded),
                              _buildInfoRow(context, 'Timeslot', appointment.timeslot, Icons.access_time),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, 'Pet Information'),
                    _buildInfoCard(
                      context,
                      [
                        _buildInfoRow(context, 'Pet Name', appointment.petname, Icons.pets),
                        _buildInfoRow(context, 'Email', appointment.email, Icons.email),
                        _buildInfoRow(context, 'Phone', appointment.phonenumber, Icons.phone),
                        _buildInfoRow(context, 'Pet Type', appointment.pettype, Icons.pets),
                        _buildInfoRow(context, 'Pet Breed', appointment.petbreed, Icons.pets),
                        _buildInfoRow(context, 'Pet Age', appointment.petage, Icons.calendar_today),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildSectionTitle(context, 'Appointment Details'),
                    _buildInfoCard(
                      context,
                      [
                        _buildInfoRow(context, 'Reason', appointment.reasonforvisit, Icons.medical_services),
                        _buildInfoRow(context, 'Type', appointment.typeofappointment, Icons.access_alarm),
                        _buildInfoRow(context, 'Doctor Preference', appointment.doctorpreference, Icons.favorite),
                        _buildInfoRow(context, 'Urgency', appointment.urgencylevel, Icons.warning_amber_rounded),
                        _buildInfoRow(context, 'Timeslot', appointment.timeslot, Icons.access_time),
                      ],
                    ),
                  ],
                ),

              if ((appointment.responseStatus ?? 'pending') == 'rejected' && 
                  (appointment.suggestedTimeslot ?? '').isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildSectionTitle(context, 'Suggested Alternative Time'),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 24 : 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: const Color.fromARGB(255, 225, 118, 82),
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
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

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
            size: isDesktop ? 48 : 32,
          ),
          SizedBox(height: isDesktop ? 16 : 8),
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 16 : 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isDesktop ? 24 : 18,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 225, 118, 82),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> infoRows) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

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

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 225, 118, 82),
            size: isDesktop ? 28 : 20,
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
                SizedBox(height: isDesktop ? 8 : 4),
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
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch ((appointment.responseStatus ?? 'pending').toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.pending;
    }
  }
}
