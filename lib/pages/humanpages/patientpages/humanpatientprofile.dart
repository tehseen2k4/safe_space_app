import 'package:flutter/material.dart';
import 'package:safe_space_app/pages/chatpages/Home_page.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/humandoctordetail.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/viewprofilehuman.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/appointmentbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/appointmentlistpage.dart';
import 'package:safe_space_app/pages/firstpage.dart';

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
      // "More" screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileHumanScreen(),
        ),
      );
      // Refresh profile data after returning
      if (user != null) {
        fetchProfileData(user!.uid);
      }
      // Reset to home tab after returning
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 1) {
      // Navigate to Appointments page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentsPage(),
        ),
      );
      // Reset to home tab after returning
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 2) {
      // Navigate to Messages page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
      // Reset to home tab after returning
      setState(() {
        _currentIndex = 0;
      });
    } else {
      // For home tab, just update the index
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

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
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                  radius: 28,
                  child: Icon(Icons.logout, color: const Color(0xFF1976D2), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1976D2),
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
                        foregroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFF1976D2)),
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
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.of(context).pop(true);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => Firstpage()),
                          (route) => false,
                        );
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
        drawer: _buildDrawer(),
        appBar: AppBar(
          title: Text(
            'SAFE-SPACE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: isDesktop ? 28 : 24,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          toolbarHeight: isDesktop ? 80 : 70,
          actions: [
            IconButton(
              icon: Icon(
                Icons.notifications,
                size: isDesktop ? 32 : 24,
              ),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : (isTablet ? 20 : 16),
                  vertical: isDesktop ? 40 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileSection(isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildQuickActionsSection(isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildDoctorsSection(isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildHospitalsSection(isDesktop),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF1976D2), const Color(0xFF1976D2).withOpacity(0.7)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: const Color(0xFF1976D2)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    patientName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Patient',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.dashboard, 'Dashboard', () {}),
            _buildDrawerItem(Icons.calendar_today, 'Appointments', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentsPage()),
              );
            }),
            _buildDrawerItem(Icons.medical_services, 'Medical Records', () {}),
            _buildDrawerItem(Icons.payment, 'Payments', () {}),
            _buildDrawerItem(Icons.settings, 'Settings', () {}),
            _buildDrawerItem(Icons.help, 'Help & Support', () {}),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () async {
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
                        backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                        radius: 28,
                        child: Icon(Icons.logout, color: const Color(0xFF1976D2), size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Logout Confirmation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color(0xFF1976D2),
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
                              foregroundColor: const Color(0xFF1976D2),
                              side: const BorderSide(color: Color(0xFF1976D2)),
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
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              await _auth.signOut();
                              Navigator.of(context).pop(true);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => Firstpage()),
                                (route) => false,
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              if (shouldLogout == true && mounted) {
                Navigator.of(context).pop();
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1976D2)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildProfileSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
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
          Container(
            height: isDesktop ? 120 : 100,
            width: isDesktop ? 120 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage('https://placekitten.com/200/200'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: isDesktop ? 24 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 26 : 22,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Text(
                  'Age: $age',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: isDesktop ? 18 : 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 4),
                Text(
                  'Sex: $sex',
                  style: TextStyle(
                    color: const Color(0xFF1976D2),
                    fontSize: isDesktop ? 16 : 14,
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

  Widget _buildQuickActionsSection(bool isDesktop) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : 18,
            color: const Color(0xFF1976D2),
          ),
        ),
        SizedBox(height: isDesktop ? 20 : 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isDesktop ? 4 : (isTablet ? 3 : 2),
          crossAxisSpacing: isDesktop ? 24 : 16,
          mainAxisSpacing: isDesktop ? 24 : 16,
          childAspectRatio: isDesktop ? 1.2 : 1.1,
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
              isDesktop,
            ),
            _buildActionCard(
              'Online Consultation',
              Icons.video_call,
              const Color(0xFF2196F3),
              () {
                // TODO: Implement online consultation
              },
              isDesktop,
            ),
            _buildActionCard(
              'Medical Records',
              Icons.medical_services,
              const Color(0xFF1976D2),
              () {
                // TODO: Implement medical records
              },
              isDesktop,
            ),
            _buildActionCard(
              'Emergency',
              Icons.emergency,
              const Color(0xFFD32F2F),
              () {
                // TODO: Implement emergency
              },
              isDesktop,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, bool isDesktop) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isDesktop ? 40 : 32,
                color: color,
              ),
              SizedBox(height: isDesktop ? 12 : 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
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

  Widget _buildDoctorsSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Doctors',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 22 : 18,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HumanDoctorDetail()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: const Color(0xFF1976D2),
                  fontWeight: FontWeight.w500,
                  fontSize: isDesktop ? 16 : 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? 20 : 16),
        SizedBox(
          height: isDesktop ? 280 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: doctorList.length,
            itemBuilder: (context, index) {
              final doctor = doctorList[index];
              return _buildDoctorCard(
                name: doctor['name'] ?? 'Unknown',
                specialty: doctor['specialization'] ?? 'Specialty Not Available',
                experience: doctor['experience'] ?? '0',
                isDesktop: isDesktop,
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
    required bool isDesktop,
  }) {
    return Container(
      width: isDesktop ? 280 : 200,
      margin: EdgeInsets.only(right: isDesktop ? 24 : 16),
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
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isDesktop ? 40 : 30,
              backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
              child: Icon(
                Icons.person,
                color: const Color(0xFF1976D2),
                size: isDesktop ? 40 : 30,
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 20 : 16,
              ),
            ),
            SizedBox(height: isDesktop ? 8 : 4),
            Text(
              specialty,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isDesktop ? 16 : 14,
              ),
            ),
            SizedBox(height: isDesktop ? 8 : 4),
            Text(
              '$experience Years Experience',
              style: TextStyle(
                color: const Color(0xFF1976D2),
                fontSize: isDesktop ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalsSection(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Hospitals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 22 : 18,
          ),
        ),
        SizedBox(height: isDesktop ? 20 : 16),
        SizedBox(
          height: isDesktop ? 280 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return _buildHospitalCard('Hospital ${index + 1}', isDesktop);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(String name, bool isDesktop) {
    return Container(
      width: isDesktop ? 280 : 200,
      margin: EdgeInsets.only(right: isDesktop ? 24 : 16),
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
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: isDesktop ? 140 : 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.local_hospital,
                  size: isDesktop ? 50 : 40,
                  color: const Color(0xFF1976D2),
                ),
              ),
            ),
            SizedBox(height: isDesktop ? 16 : 12),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 20 : 16,
              ),
            ),
            SizedBox(height: isDesktop ? 8 : 4),
            Text(
              '24/7 Emergency Care',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isDesktop ? 16 : 14,
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
