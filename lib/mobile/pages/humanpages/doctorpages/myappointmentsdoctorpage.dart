import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/humanpages/doctorpages/appointmentdetailpage.dart';
import 'package:intl/intl.dart';

class Humandoctorappointmentlistpage extends StatefulWidget {
  @override
  _HumandoctorappointmentlistpageState createState() =>
      _HumandoctorappointmentlistpageState();
}

class _HumandoctorappointmentlistpageState
    extends State<Humandoctorappointmentlistpage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  List<HumanAppointmentDb> _allAppointments = [];
  List<HumanAppointmentDb> _pendingAppointments = [];
  List<HumanAppointmentDb> _confirmedAppointments = [];
  List<HumanAppointmentDb> _completedAppointments = [];
  List<HumanAppointmentDb> _cancelledAppointments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorUid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _allAppointments = [];
          _categorizeAppointments();
        });
        return;
      }

      setState(() {
        _allAppointments = querySnapshot.docs
            .map((doc) => HumanAppointmentDb.fromJson(doc.data()))
            .toList();
        _categorizeAppointments();
      });
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  void _categorizeAppointments() {
    _pendingAppointments = _allAppointments
        .where((appointment) => appointment.responseStatus == 'pending')
        .toList();
    _confirmedAppointments = _allAppointments
        .where((appointment) => appointment.responseStatus == 'confirmed')
        .toList();
    _completedAppointments = _allAppointments
        .where((appointment) => appointment.responseStatus == 'completed')
        .toList();
    _cancelledAppointments = _allAppointments
        .where((appointment) => appointment.responseStatus == 'cancelled')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Appointments',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Colors.teal,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: TextStyle(fontSize: 12),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pending_actions, size: 16),
                      SizedBox(width: 4),
                      Text('Pending'),
                      if (_pendingAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _pendingAppointments.length.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 16),
                      SizedBox(width: 4),
                      Text('Confirmed'),
                      if (_confirmedAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _confirmedAppointments.length.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all, size: 16),
                      SizedBox(width: 4),
                      Text('Completed'),
                      if (_completedAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _completedAppointments.length.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, size: 16),
                      SizedBox(width: 4),
                      Text('Cancelled'),
                      if (_cancelledAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _cancelledAppointments.length.toString(),
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList(_pendingAppointments),
          _buildAppointmentList(_confirmedAppointments),
          _buildAppointmentList(_completedAppointments),
          _buildAppointmentList(_cancelledAppointments),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<HumanAppointmentDb> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAppointments,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index]);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(HumanAppointmentDb appointment) {
    Color statusColor = _getStatusColor(appointment.responseStatus ?? 'pending');
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentDetailsPage(
                  appointment: appointment,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment.responseStatus?.toUpperCase() ?? 'PENDING',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      appointment.appointmentId,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal[100],
                      child: Icon(Icons.person, color: Colors.teal),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.username,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Age: ${appointment.age} | ${appointment.gender}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.watch_later, size: 18, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      appointment.timeslot,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.description, size: 18, color: Colors.teal),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.reasonforvisit,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urgency: ${appointment.urgencylevel}',
                      style: TextStyle(
                        color: _getUrgencyColor(appointment.urgencylevel),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentDetailsPage(
                              appointment: appointment,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
