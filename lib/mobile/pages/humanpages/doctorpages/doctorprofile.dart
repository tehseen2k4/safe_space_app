import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/mobile/pages/humanpages/doctorpages/myappointmentsdoctorpage.dart';
import 'package:safe_space_app/mobile/pages/humanpages/doctorpages/petdoctorappointmentlistpage.dart';
import 'package:safe_space_app/mobile/pages/humanpages/doctorpages/viewprofiledoctor.dart';
import 'package:safe_space_app/mobile/pages/humanpages/doctorpages/doctoravailability.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/humanpages/doctorpages/appointmentdetailpage.dart';
import 'package:safe_space_app/mobile/pages/petpages/petappointmentdetailpage.dart';

class Doctorlogin extends StatefulWidget {
  const Doctorlogin({super.key});

  @override
  State<Doctorlogin> createState() => _DoctorloginState();
}

class _DoctorloginState extends State<Doctorlogin> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String doctorName = "Doctor Name";
  String specialization = "**";
  String qualification = "***";
  String doctorType = '';
  Future<List>? _appointmentsFuture;
  Map<String, dynamic> doctor = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    if (user != null) {
      fetchProfileData(user!.uid);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchProfileData(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          doctor = data;
          doctorName = data['name'] ?? "Doctor's Name";
          specialization = data['specialization'] ?? "**";
          qualification = data['qualification'] ?? "***";
          doctorType = data['doctorType'] ?? "";
          _appointmentsFuture = doctorType == "Human"
              ? _fetchHumanAppointments()
              : _fetchPetAppointments();
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  void _onBottomNavTap(int index) async {
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileDoctorScreen(),
        ),
      );
      if (user != null) {
        fetchProfileData(user!.uid);
      }
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorAvailabilityScreen(),
        ),
      );
      setState(() {
        _currentIndex = 0;
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<List<PetAppointmentDb>> _fetchPetAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('petappointments')
          .where('doctorUid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => PetAppointmentDb.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  Future<List<HumanAppointmentDb>> _fetchHumanAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('doctorUid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs
          .map((doc) => HumanAppointmentDb.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching appointments: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 24),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            actionsPadding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
            title: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  radius: 28,
                  child: Icon(Icons.logout, color: Colors.teal, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to log out?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.teal,
                        side: const BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        return shouldLogout ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text(
            'SAFE-SPACE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          toolbarHeight: 70,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileSection(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  _buildAppointmentsSection(),
                  const SizedBox(height: 24),
                  _buildStatisticsSection(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.teal.withOpacity(0.1),
            child: Icon(Icons.person, size: 40, color: Colors.teal),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. $doctorName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  specialization,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  qualification,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontSize: 14,
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

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              'View Appointments',
              Icons.calendar_today,
              Colors.teal,
              () {
                if (doctorType.toLowerCase() == "human") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Humandoctorappointmentlistpage(),
                    ),
                  );
                } else if (doctorType.toLowerCase() == "veterinary") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PetDoctorAppointmentsListPage(),
                    ),
                  );
                }
              },
            ),
            _buildActionCard(
              'Set Availability',
              Icons.access_time,
              Colors.blue,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorAvailabilityScreen(),
                  ),
                );
              },
            ),
            _buildActionCard(
              'Medical Records',
              Icons.medical_services,
              Colors.purple,
              () {
                // TODO: Implement medical records
              },
            ),
            _buildActionCard(
              'Messages',
              Icons.message,
              Colors.orange,
              () {
                // TODO: Implement messages
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Today\'s Appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton.icon(
                onPressed: () {
                  if (doctorType.toLowerCase() == "human") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Humandoctorappointmentlistpage(),
                      ),
                    );
                  } else if (doctorType.toLowerCase() == "veterinary") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDoctorAppointmentsListPage(),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.calendar_month,
                  size: 18,
                  color: Colors.teal,
                ),
                label: const Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No appointments for today'),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length > 3 ? 3 : snapshot.data!.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data![index];
                return _buildAppointmentCard(appointment);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: Icon(Icons.person, color: Colors.teal),
        ),
        title: Text(
          appointment.username ?? 'Patient Name',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Time: ${appointment.timeslot ?? 'N/A'}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${appointment.status ?? 'Pending'}',
              style: TextStyle(
                color: _getStatusColor(appointment.status?.toString()),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            if (doctorType.toLowerCase() == "human") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentDetailsPage(appointment: appointment),
                ),
              );
            } else if (doctorType.toLowerCase() == "veterinary") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetAppointmentDetailsPage(appointment: appointment),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Total Patients',
              '150',
              Icons.people,
              Colors.blue,
            ),
            _buildStatCard(
              'Appointments',
              '25',
              Icons.calendar_today,
              Colors.green,
            ),
            _buildStatCard(
              'Reviews',
              '4.8',
              Icons.star,
              Colors.amber,
            ),
            _buildStatCard(
              'Earnings',
              '\$2,500',
              Icons.attach_money,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
