import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/myappointmentsdoctorpage.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/petdoctorappointmentlistpage.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/viewprofiledoctor.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/doctoravailability.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/appointmentdetailpage.dart';
import 'package:safe_space_app/pages/petpages/petappointmentdetailpage.dart';
import 'package:safe_space_app/pages/firstpage.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> with SingleTickerProviderStateMixin {
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
      // "More" screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileDoctorScreen(),
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
      // Navigate to DoctorAvailability page
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorAvailability(),
        ),
      );
      // Reset to home tab after returning
      setState(() {
        _currentIndex = 0;
      });
    } else {
      // For other tabs (home, messages), just update the index
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<List<PetAppointmentDb>> _fetchPetAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in');
      return [];
    }

    try {
      print('Fetching pet appointments for doctor: ${user.uid}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('petappointments')
          .where('doctorUid', isEqualTo: user.uid)
          .get();

      print('Query returned ${querySnapshot.docs.length} appointments');
      
      if (querySnapshot.docs.isEmpty) {
        print('No appointments found for this doctor');
        return [];
      }

      final appointments = querySnapshot.docs
          .map((doc) {
            print('Processing appointment: ${doc.id}');
            return PetAppointmentDb.fromJson(doc.data());
          })
          .toList();
      
      print('Successfully processed ${appointments.length} appointments');
      return appointments;
    } catch (e) {
      print("Error fetching pet appointments: $e");
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
        drawer: _buildDrawer(),
        appBar: AppBar(
          title: Text(
            'Doctor Profile',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          toolbarHeight: isDesktop ? 80 : 70,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ],
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
                    _buildProfileHeader(isDesktop),
                    SizedBox(height: isDesktop ? 32 : 24),
                    _buildProfileDetails(isDesktop),
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
                color: Colors.teal,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal, Colors.teal.shade300],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Dr. $doctorName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    specialization,
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
            }),
            _buildDrawerItem(Icons.medical_services, 'Services', () {}),
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
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  Widget _buildProfileHeader(bool isDesktop) {
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
              backgroundImage: NetworkImage(doctor['profileImage'] ?? ''),
            ),
            SizedBox(width: isDesktop ? 24 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? 'Dr. Name',
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 8 : 4),
                  Text(
                    doctor['specialization'] ?? 'Specialization',
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
                        '${doctor['rating'] ?? '4.5'}',
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

  Widget _buildProfileDetails(bool isDesktop) {
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
            _buildDetailRow('Qualification', doctor['qualification'] ?? 'N/A', isDesktop),
            _buildDetailRow('Experience', '${doctor['experience'] ?? '0'} years', isDesktop),
            _buildDetailRow('Clinic Name', doctor['clinicName'] ?? 'N/A', isDesktop),
            _buildDetailRow('Consultation Fee', '\$${doctor['fees'] ?? '0'}', isDesktop),
            _buildDetailRow('Contact', doctor['phone'] ?? 'N/A', isDesktop),
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
            _buildTimeRow('Start Time', doctor['startTime'] ?? 'N/A', isDesktop),
            _buildTimeRow('End Time', doctor['endTime'] ?? 'N/A', isDesktop),
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
              children: (doctor['availableDays'] as List<dynamic>? ?? [])
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
            // Handle edit profile
          },
          icon: Icon(Icons.edit, size: isDesktop ? 24 : 20),
          label: Text(
            'Edit Profile',
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
            // Handle view appointments
          },
          icon: Icon(Icons.calendar_today, size: isDesktop ? 24 : 20),
          label: Text(
            'View Appointments',
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

class ProfilePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double imageSize = MediaQuery.of(context).size.width * 0.4;

    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/images/one.jpg'),
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
      ],
    );
  }
}
