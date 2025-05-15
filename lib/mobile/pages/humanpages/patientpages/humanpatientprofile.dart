import 'package:flutter/material.dart';
import 'package:safe_space_app/mobile/pages/chatpages/Home_page.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/humandoctordetail.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/viewprofilehuman.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/appointmentbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/appointmentlistpage.dart';

class HumanPatientProfile extends StatefulWidget {
  const HumanPatientProfile({super.key});

  @override
  _HumanPatientProfileState createState() => _HumanPatientProfileState();
}

class _HumanPatientProfileState extends State<HumanPatientProfile> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final double hospitalCardHeight = 200;
  final double hospitalCardWidth = 150;
  final double doctorCardHeight = 200;
  final double doctorCardWidth = 160;

  String patientName = "Patient Name";
  String age = "**";
  String sex = "***";
  String bloodGroup = "Not specified";

  List<Map<String, dynamic>> doctorList = [];

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
      fetchDoctors();
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
          .collection('humanpatients')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          patientName = data['name'] ?? "Patient Name";
          age = data['age']?.toString() ?? "**";
          sex = data['sex'] ?? "***";
          bloodGroup = data['bloodgroup'] ?? "Not specified";
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> fetchDoctors() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Human')
          .get();

      final fetchedDoctors = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        doctorList = fetchedDoctors;
      });
    } catch (e) {
      print("Error fetching doctors: $e");
    }
  }

  void _onBottomNavTap(int index) async {
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileHumanScreen(),
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
          builder: (context) => AppointmentsPage(),
        ),
      );
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'SAFE-SPACE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 24),
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
                _buildDoctorsSection(),
                const SizedBox(height: 24),
                _buildHospitalsSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
            backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
            child: const Icon(Icons.person, size: 40, color: Color(0xFF1976D2)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Age: $age years',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Blood Group: $bloodGroup',
                  style: const TextStyle(
                    color: Color(0xFF1976D2),
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
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              'Book Appointment',
              Icons.calendar_today,
              const Color(0xFF1976D2),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookAppointmentPage()),
                );
              },
            ),
            _buildActionCard(
              'Online Consultation',
              Icons.video_call,
              const Color(0xFF2196F3),
              () {
                // TODO: Implement online consultation
              },
            ),
            _buildActionCard(
              'Medical Records',
              Icons.medical_services,
              const Color(0xFF1976D2),
              () {
                // TODO: Implement medical records
              },
            ),
            _buildActionCard(
              'Emergency',
              Icons.emergency,
              const Color(0xFFD32F2F),
              () {
                // TODO: Implement emergency
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
              Icon(
                icon,
                size: 32,
                color: color,
              ),
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

  Widget _buildDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Doctors',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HumanDoctorDetail()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: doctorList.length,
            itemBuilder: (context, index) {
              final doctor = doctorList[index];
              return _buildDoctorCard(
                name: doctor['name'] ?? 'Unknown',
                specialty: doctor['specialization'] ?? 'Specialty Not Available',
                experience: doctor['experience'] ?? '0',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String experience,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: Color(0xFF1976D2),
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              specialty,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$experience Years Experience',
              style: const TextStyle(
                color: Color(0xFF1976D2),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Hospitals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildHospitalCard('Hospital ${index + 1}');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(String name) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: Color(0xFF1976D2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '24/7 Emergency Care',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
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
        selectedItemColor: const Color(0xFF1976D2),
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
            label: 'Appointments',
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
