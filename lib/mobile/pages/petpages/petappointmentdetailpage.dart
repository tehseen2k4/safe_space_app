import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petappointment_db.dart';

class PetAppointmentDetailsPage extends StatelessWidget {
  final PetAppointmentDb appointment;

  const PetAppointmentDetailsPage({Key? key, required this.appointment})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Pet Appointment Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFE17652),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Pet Information'),
            _buildInfoCard([
              _buildInfoRow('Pet Name', appointment.username, Icons.pets),
              _buildInfoRow('Email', appointment.email, Icons.email),
              _buildInfoRow('Phone', appointment.phonenumber, Icons.phone),
              _buildInfoRow('Gender', appointment.gender, Icons.pets),
              _buildInfoRow('Age', appointment.age, Icons.calendar_today),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Appointment Details'),
            _buildInfoCard([
              _buildInfoRow('Reason', appointment.reasonforvisit, Icons.medical_services),
              _buildInfoRow('Type', appointment.typeofappointment, Icons.access_alarm),
              _buildInfoRow('Doctor Preference', appointment.doctorpreference, Icons.favorite),
              _buildInfoRow('Urgency', appointment.urgencylevel, Icons.warning_amber_rounded),
              _buildInfoRow('Timeslot', appointment.timeslot, Icons.access_time),
            ]),
            if ((appointment.responseStatus ?? 'pending') == 'rejected' && 
                (appointment.suggestedTimeslot ?? '').isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildSectionTitle('Suggested Alternative Time'),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFFE17652),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            appointment.suggestedTimeslot ?? '',
                            style: const TextStyle(
                              fontSize: 16,
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
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
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
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${(appointment.responseStatus ?? 'pending').toUpperCase()}',
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE17652),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> infoRows) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: infoRows,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE17652),
            size: 20,
          ),
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
