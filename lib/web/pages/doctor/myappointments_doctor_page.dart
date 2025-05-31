import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyAppointmentsDoctorPage extends StatefulWidget {
  const MyAppointmentsDoctorPage({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsDoctorPage> createState() => _MyAppointmentsDoctorPageState();
}

class _MyAppointmentsDoctorPageState extends State<MyAppointmentsDoctorPage> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TabController _tabController;
  List<dynamic> _allAppointments = [];
  List<dynamic> _pendingAppointments = [];
  List<dynamic> _confirmedAppointments = [];
  List<dynamic> _completedAppointments = [];
  List<dynamic> _cancelledAppointments = [];
  Set<String> _expandedCards = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Get doctor type from Firestore
      final doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (!doctorDoc.exists) {
        print("Doctor document not found");
        return;
      }

      final doctorType = doctorDoc.data()?['doctorType'] as String?;
      print("Doctor type: $doctorType"); // Debug print

      if (doctorType == null) {
        print("Doctor type not found");
        return;
      }

      // Determine collection based on doctor type
      final collectionName = doctorType.toLowerCase().trim() == 'human' ? 'appointments' : 'petappointments';
      print("Using collection: $collectionName"); // Debug print

      final querySnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('doctorUid', isEqualTo: user.uid)
          .get();

      print("Found ${querySnapshot.docs.length} appointments"); // Debug print

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _allAppointments = [];
          _categorizeAppointments();
        });
        return;
      }

      setState(() {
        _allAppointments = querySnapshot.docs.map((doc) {
          final data = doc.data();
          print("Creating appointment from data: ${data['typeofappointment']}"); // Debug print
          // Create appointment based on doctor type
          if (doctorType.toLowerCase() == 'human') {
            print("Creating HumanAppointmentDb"); // Debug print
            return HumanAppointmentDb.fromJson(data);
          } else {
            print("Creating PetAppointmentDb"); // Debug print
            return PetAppointmentDb.fromJson(data);
          }
        }).toList();
        _categorizeAppointments();
      });
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  void _categorizeAppointments() {
    _pendingAppointments = _allAppointments
        .where((appointment) => appointment.responseStatus == null || appointment.responseStatus == 'pending')
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

  Future<void> _handleAppointmentResponse(dynamic appointment, String status) async {
    try {
      // Clear any existing notes when starting a new response
      _notesController.clear();
      
      String response = status == 'confirmed' ? 'Appointment confirmed' : 'Appointment rejected';
      
      // Get the collection name based on appointment type
      String collectionName = appointment is HumanAppointmentDb ? 'appointments' : 'petappointments';
      
      // Update the appointment in Firestore using the correct collection
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(appointment.documentId)
          .update({
        'doctorResponse': response,
        'responseStatus': status,
        'responseTimestamp': FieldValue.serverTimestamp(),
        'doctorNotes': _notesController.text.isNotEmpty ? _notesController.text : '',
      });

      // Refresh the appointments list
      await _fetchAppointments();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment ${status.toLowerCase()} successfully'),
            backgroundColor: status == 'confirmed' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error updating appointment: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAppointmentAsCompleted(dynamic appointment) async {
    try {
      print("Appointment type: ${appointment.runtimeType}"); // Debug print for appointment type
      
      // Get the collection name based on appointment type
      String collectionName;
      if (appointment is HumanAppointmentDb) {
        print("Detected as HumanAppointmentDb"); // Debug print
        collectionName = 'appointments';
      } else if (appointment is PetAppointmentDb) {
        print("Detected as PetAppointmentDb"); // Debug print
        collectionName = 'petappointments';
      } else {
        print("Unknown type: ${appointment.runtimeType}"); // Debug print
        throw Exception('Unknown appointment type');
      }
      
      print("Marking as completed in collection: $collectionName"); // Debug print
      print("Document ID: ${appointment.documentId}"); // Debug print
      
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(appointment.documentId)
          .update({
        'responseStatus': 'completed',
        'responseTimestamp': FieldValue.serverTimestamp(),
      });

      // Refresh the appointments list
      await _fetchAppointments();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error marking appointment as completed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: Column(
        children: [
          // Header with Stats Cards
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Appointments',
                        value: _allAppointments.length.toString(),
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.lightBlue],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Pending',
                        value: _pendingAppointments.length.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.deepOrange],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Confirmed',
                        value: _confirmedAppointments.length.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Cancelled',
                        value: _cancelledAppointments.length.toString(),
                        icon: Icons.cancel_outlined,
                        color: Colors.red,
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.teal,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, size: 20),
                      const SizedBox(width: 8),
                      const Text('Pending'),
                      if (_pendingAppointments.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _pendingAppointments.length.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
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
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      const Text('Confirmed'),
                      if (_confirmedAppointments.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _confirmedAppointments.length.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
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
                      const Icon(Icons.done_all, size: 20),
                      const SizedBox(width: 8),
                      const Text('Completed'),
                      if (_completedAppointments.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _completedAppointments.length.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
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
                      const Icon(Icons.cancel_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Cancelled'),
                      if (_cancelledAppointments.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _cancelledAppointments.length.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
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
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<dynamic> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(appointments[index]);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    Color statusColor = _getStatusColor(appointment.responseStatus ?? 'pending');
    bool isExpanded = _expandedCards.contains(appointment.appointmentId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedCards.remove(appointment.appointmentId);
                  } else {
                    _expandedCards.add(appointment.appointmentId);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            (appointment.responseStatus ?? 'pending').toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Appointment ID: ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              appointment.appointmentId,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.teal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.teal,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.teal[100],
                          child: Icon(
                            appointment is PetAppointmentDb ? Icons.pets : Icons.person,
                            color: Colors.teal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appointment.timeslot,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.description,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 8),
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Urgency: ${appointment.urgencylevel}',
                          style: TextStyle(
                            color: _getUrgencyColor(appointment.urgencylevel),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Contact Information', [
                      _buildDetailRow('Email', appointment.email, Icons.email),
                      _buildDetailRow('Phone', appointment.phonenumber, Icons.phone),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('Appointment Details', [
                      _buildDetailRow('Type', appointment.typeofappointment, Icons.access_alarm),
                      _buildDetailRow('Doctor Preference', appointment.doctorpreference, Icons.favorite),
                    ]),
                    const SizedBox(height: 16),
                    _buildDetailSection('Notes', [
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Add notes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 3,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    if (appointment.responseStatus == 'pending')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _handleAppointmentResponse(appointment, 'confirmed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Accept'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _handleAppointmentResponse(appointment, 'cancelled'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Reject'),
                          ),
                        ],
                      )
                    else if (appointment.responseStatus == 'confirmed')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _markAppointmentAsCompleted(appointment),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Mark as Completed'),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.teal),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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