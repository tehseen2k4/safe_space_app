import 'package:flutter/material.dart';

class HumanDoctorFullDetailPage extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const HumanDoctorFullDetailPage({Key? key, required this.doctor}) : super(key: key);

  @override
  _HumanDoctorFullDetailPageState createState() => _HumanDoctorFullDetailPageState();
}

class _HumanDoctorFullDetailPageState extends State<HumanDoctorFullDetailPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctor Details',
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        toolbarHeight: isDesktop ? 80 : 70,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32 : 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(isDesktop),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildDetailCard(isDesktop),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildAvailabilitySection(isDesktop),
                  SizedBox(height: isDesktop ? 32 : 24),
                  _buildActionButtons(context, isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool isDesktop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: isDesktop ? 60 : 40,
              backgroundImage: NetworkImage(widget.doctor['profileImage'] ?? ''),
            ),
            SizedBox(width: isDesktop ? 24 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor['name'] ?? 'Dr. Name',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 8 : 4),
                  Text(
                    widget.doctor['specialization'] ?? 'Specialization',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 8 : 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: isDesktop ? 24 : 20,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${widget.doctor['rating'] ?? '4.5'}',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(bool isDesktop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Professional Details',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            _buildDetailRow('Qualification', widget.doctor['qualification'] ?? 'N/A', isDesktop),
            _buildDetailRow('Experience', '${widget.doctor['experience'] ?? '0'} years', isDesktop),
            _buildDetailRow('Clinic Name', widget.doctor['clinicName'] ?? 'N/A', isDesktop),
            _buildDetailRow('Consultation Fee', '\$${widget.doctor['fees'] ?? '0'}', isDesktop),
            _buildDetailRow('Contact', widget.doctor['phone'] ?? 'N/A', isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(bool isDesktop) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            _buildTimeRow('Start Time', widget.doctor['startTime'] ?? 'N/A', isDesktop),
            _buildTimeRow('End Time', widget.doctor['endTime'] ?? 'N/A', isDesktop),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              'Available Days',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: isDesktop ? 8 : 4),
            Wrap(
              spacing: isDesktop ? 12 : 8,
              runSpacing: isDesktop ? 12 : 8,
              children: (widget.doctor['availableDays'] as List<dynamic>? ?? [])
                  .map((day) => Chip(
                        label: Text(
                          day.toString(),
                          style: TextStyle(fontSize: isDesktop ? 16 : 14),
                        ),
                        backgroundColor: Colors.teal[100],
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String time, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 8 : 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Handle book appointment
          },
          icon: Icon(Icons.calendar_today, size: isDesktop ? 24 : 20),
          label: Text(
            'Book Appointment',
            style: TextStyle(fontSize: isDesktop ? 18 : 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24,
              vertical: isDesktop ? 16 : 12,
            ),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // Handle view reviews
          },
          icon: Icon(Icons.rate_review, size: isDesktop ? 24 : 20),
          label: Text(
            'View Reviews',
            style: TextStyle(fontSize: isDesktop ? 18 : 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24,
              vertical: isDesktop ? 16 : 12,
            ),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
            ),
          ),
        ),
      ],
    );
  }
} 