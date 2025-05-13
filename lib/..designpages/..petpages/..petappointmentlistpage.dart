import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:safe_space_app/pages/petpages/petappointmentbooking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/petpages/petappointmentdetailpage.dart';

class PetAppointmentsListPage extends StatefulWidget {
  @override
  _PetAppointmentsListPageState createState() => _PetAppointmentsListPageState();
}

class _PetAppointmentsListPageState extends State<PetAppointmentsListPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  List<PetAppointmentDb> _allAppointments = [];
  List<PetAppointmentDb> _pendingAppointments = [];
  List<PetAppointmentDb> _confirmedAppointments = [];
  List<PetAppointmentDb> _completedAppointments = [];
  List<PetAppointmentDb> _cancelledAppointments = [];

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
          .collection('petappointments')
          .where('uid', isEqualTo: user.uid)
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
            .map((doc) => PetAppointmentDb.fromJson(doc.data()))
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Pet Appointments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isDesktop ? 60 : 48),
          child: Container(
            color: const Color.fromARGB(255, 225, 118, 82),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 14 : 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: isDesktop ? 14 : 12,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pending_actions, size: isDesktop ? 20 : 16),
                      SizedBox(width: isDesktop ? 8 : 4),
                      Text('Pending'),
                      if (_pendingAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: isDesktop ? 8 : 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 8 : 4,
                            vertical: isDesktop ? 2 : 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _pendingAppointments.length.toString(),
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: isDesktop ? 20 : 16),
                      SizedBox(width: isDesktop ? 8 : 4),
                      Text('Confirmed'),
                      if (_confirmedAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: isDesktop ? 8 : 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 8 : 4,
                            vertical: isDesktop ? 2 : 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _confirmedAppointments.length.toString(),
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all, size: isDesktop ? 20 : 16),
                      SizedBox(width: isDesktop ? 8 : 4),
                      Text('Completed'),
                      if (_completedAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: isDesktop ? 8 : 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 8 : 4,
                            vertical: isDesktop ? 2 : 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _completedAppointments.length.toString(),
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel_outlined, size: isDesktop ? 20 : 16),
                      SizedBox(width: isDesktop ? 8 : 4),
                      Text('Cancelled'),
                      if (_cancelledAppointments.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(left: isDesktop ? 8 : 4),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 8 : 4,
                            vertical: isDesktop ? 2 : 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _cancelledAppointments.length.toString(),
                            style: TextStyle(
                              fontSize: isDesktop ? 12 : 10,
                            ),
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
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentList(_pendingAppointments),
            _buildAppointmentList(_confirmedAppointments),
            _buildAppointmentList(_completedAppointments),
            _buildAppointmentList(_cancelledAppointments),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookAppointmentPetPage(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: isDesktop ? 32 : 24,
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<PetAppointmentDb> appointments) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: isDesktop ? 96 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: isDesktop ? 24 : 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 18,
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
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index]);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(PetAppointmentDb appointment) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    Color statusColor = _getStatusColor(appointment.responseStatus ?? 'pending');
    
    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 24 : 16),
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
                builder: (context) => PetAppointmentDetailsPage(
                  appointment: appointment,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 16 : 12,
                        vertical: isDesktop ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment.responseStatus?.toUpperCase() ?? 'PENDING',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: isDesktop ? 14 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      appointment.appointmentId,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 225, 118, 82).withOpacity(0.1),
                      radius: isDesktop ? 30 : 24,
                      child: Icon(
                        Icons.pets,
                        color: const Color.fromARGB(255, 225, 118, 82),
                        size: isDesktop ? 32 : 24,
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.username,
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 8 : 4),
                          Text(
                            'Type: ${appointment.typeofappointment}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isDesktop ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                Row(
                  children: [
                    Icon(
                      Icons.watch_later,
                      size: isDesktop ? 24 : 18,
                      color: const Color.fromARGB(255, 225, 118, 82),
                    ),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Text(
                      appointment.timeslot,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: isDesktop ? 24 : 18,
                      color: const Color.fromARGB(255, 225, 118, 82),
                    ),
                    SizedBox(width: isDesktop ? 12 : 8),
                    Expanded(
                      child: Text(
                        appointment.reasonforvisit,
                        style: TextStyle(
                          fontSize: isDesktop ? 16 : 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 24 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urgency: ${appointment.urgencylevel}',
                      style: TextStyle(
                        color: _getUrgencyColor(appointment.urgencylevel),
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetAppointmentDetailsPage(
                              appointment: appointment,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 20,
                          vertical: isDesktop ? 12 : 8,
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 16 : 14,
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
