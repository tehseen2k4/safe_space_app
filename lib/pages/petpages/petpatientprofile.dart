import 'package:flutter/material.dart';
import 'package:safe_space_app/pages/petpages/petappointmentlistpage.dart';
import 'package:safe_space_app/pages/petpages/viewprofile.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/appointmentbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/petpages/petappointmentbooking.dart';
import 'package:safe_space_app/pages/petpages/petdoctordetail.dart';
import 'package:safe_space_app/pages/firstpage.dart';

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
      debugPrint('Starting to fetch veterinary doctors...');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Veterinary')
          .get();

      final fetchedDoctors = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      debugPrint('=== Doctor Fetch Results ===');
      debugPrint('Total doctors fetched: ${fetchedDoctors.length}');
      for (var doctor in fetchedDoctors) {
        debugPrint('Doctor Details:');
        debugPrint('- Name: ${doctor['name']}');
        debugPrint('- Type: ${doctor['doctorType']}');
        debugPrint('- Specialization: ${doctor['specialization']}');
        debugPrint('------------------------');
      }

      setState(() {
        doctorList = fetchedDoctors;
      });
    } catch (e) {
      debugPrint('Error fetching doctors: $e');
    }
  }

  void _onBottomNavTap(int index) async {
    if (index == 3) {
      // "More" screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileScreen(),
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
          builder: (context) => PetAppointmentsListPage(),
        ),
      );
      // Reset to home tab after returning
      setState(() {
        _currentIndex = 0;
      });
    } else if (index == 2) {
      // Navigate to Messages page
      // TODO: Implement pet messages page
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
                  backgroundColor: const Color.fromARGB(255, 225, 118, 82).withOpacity(0.1),
                  radius: 28,
                  child: Icon(Icons.logout, color: const Color.fromARGB(255, 225, 118, 82), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 225, 118, 82),
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
                        foregroundColor: const Color.fromARGB(255, 225, 118, 82),
                        side: const BorderSide(color: Color.fromARGB(255, 225, 118, 82)),
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
                        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
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
        backgroundColor: Colors.grey[50],
        drawer: isDesktop ? null : _buildDrawer(),
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
          backgroundColor: const Color.fromARGB(255, 225, 118, 82),
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
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
            ),
            child: Row(
              children: [
                if (isDesktop)
                  SizedBox(
                    width: 250,
                    child: _buildDrawer(),
                  ),
                Expanded(
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
              ],
            ),
          ),
        ),
        bottomNavigationBar: isDesktop ? null : _buildBottomNavigationBar(),
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
                color: const Color.fromARGB(255, 225, 118, 82),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 225, 118, 82),
                    const Color.fromARGB(255, 225, 118, 82).withOpacity(0.7),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.pets, size: 35, color: const Color.fromARGB(255, 225, 118, 82)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    petName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Pet',
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
                MaterialPageRoute(builder: (context) => PetAppointmentsListPage()),
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
                        backgroundColor: const Color.fromARGB(255, 225, 118, 82).withOpacity(0.1),
                        radius: 28,
                        child: Icon(Icons.logout, color: const Color.fromARGB(255, 225, 118, 82), size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Logout Confirmation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 225, 118, 82),
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
                              foregroundColor: const Color.fromARGB(255, 225, 118, 82),
                              side: const BorderSide(color: Color.fromARGB(255, 225, 118, 82)),
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
                              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
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
      leading: Icon(icon, color: const Color.fromARGB(255, 225, 118, 82)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
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
                  style: TextStyle(
                    color: const Color.fromARGB(255, 225, 118, 82),
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

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
          crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 2),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              'Book Appointment',
              Icons.calendar_today,
              const Color.fromARGB(255, 225, 118, 82),
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

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
                  color: Color.fromARGB(255, 225, 118, 82),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isDesktop ? 300 : 200,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: isDesktop ? 1.5 : 1,
              mainAxisSpacing: 16,
            ),
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
              backgroundColor: const Color.fromARGB(255, 225, 118, 82).withOpacity(0.1),
              child: Icon(Icons.person, color: const Color.fromARGB(255, 225, 118, 82), size: 30),
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
              style: TextStyle(
                color: const Color.fromARGB(255, 225, 118, 82),
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

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
          height: isDesktop ? 300 : 200,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: isDesktop ? 1.5 : 1,
              mainAxisSpacing: 16,
            ),
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
                color: const Color.fromARGB(255, 225, 118, 82).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.local_hospital,
                  size: 40,
                  color: const Color.fromARGB(255, 225, 118, 82),
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
        selectedItemColor: const Color.fromARGB(255, 225, 118, 82),
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
