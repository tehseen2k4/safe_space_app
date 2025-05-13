import 'package:flutter/material.dart';
import 'package:safe_space_app/mobile/pages/petpages/petappointmentlistpage.dart';
import 'package:safe_space_app/mobile/pages/petpages/viewprofile.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/appointmentbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/petpages/petappointmentbooking.dart';
import 'package:safe_space_app/mobile/pages/petpages/petdoctordetail.dart';

class Petpatientprofile extends StatefulWidget {
  const Petpatientprofile({super.key});

  @override
  _PetpatientprofileState createState() => _PetpatientprofileState();
}

class _PetpatientprofileState extends State<Petpatientprofile> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final double hospitalCardHeight =
      200; // You can change this value to any height you want
  final double hospitalCardWidth = 200; // Set your desired width
  final double doctorCardHeight = 200;
  final double doctorCardWidth = 160;

  String petName = "Pet Name";
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
          .collection('pets')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
          petName = data['name'] ?? "Pet Name";
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
          .where('doctorType', isEqualTo: 'Veterinary')
          .get();

      final fetchedDoctors = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        doctorList = fetchedDoctors;
      });
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  void _onBottomNavTap(int index) async {
    if (index == 3) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileScreen(),
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
          builder: (context) => PetAppointmentsListPage(),
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
                  backgroundColor: const Color(0xFFE17652).withOpacity(0.1),
                  radius: 28,
                  child: const Icon(Icons.logout, color: Color(0xFFE17652), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFE17652),
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
                        foregroundColor: const Color(0xFFE17652),
                        side: const BorderSide(color: Color(0xFFE17652)),
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
                        backgroundColor: const Color(0xFFE17652),
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
          backgroundColor: const Color(0xFFE17652),
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
                  _buildDoctorsSection(),
                  const SizedBox(height: 24),
                  _buildHospitalsSection(),
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
          Container(
            height: 100,
            width: 100,
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
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Age: $age',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sex: $sex',
                  style: const TextStyle(
                    color: Color(0xFFE17652),
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
              'Book Appointment',
              Icons.calendar_today,
              const Color(0xFFE17652),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookAppointmentPetPage()),
                );
              },
            ),
            _buildActionCard(
              'Online Consultation',
              Icons.video_call,
              Colors.blue,
              () {
                // TODO: Implement online consultation
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
              'Emergency',
              Icons.emergency,
              Colors.red,
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

  Widget _buildDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Veterinarians',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetDoctorDetail()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFFE17652),
                  fontWeight: FontWeight.w500,
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
              backgroundColor: const Color(0xFFE17652).withOpacity(0.1),
              child: const Icon(Icons.person, color: Color(0xFFE17652), size: 30),
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
                color: Color(0xFFE17652),
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
          'Nearby Veterinary Hospitals',
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
              return _buildHospitalCard('Vet Hospital ${index + 1}');
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
                color: const Color(0xFFE17652).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: Color(0xFFE17652),
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
        selectedItemColor: const Color(0xFFE17652),
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
