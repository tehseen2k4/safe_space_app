import 'package:flutter/material.dart';
import 'package:safe_space/pages/chatpages/Home_page.dart';
import 'package:safe_space/pages/patientpages/humandoctordetail.dart';
import 'package:safe_space/pages/viewprofilehuman.dart';
import 'package:safe_space/pages/patientpages/appointmentbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space/pages/appointmentlistpage.dart';

class HumanPatientProfile extends StatefulWidget {
  @override
  _HumanPatientProfileState createState() => _HumanPatientProfileState();
}

class _HumanPatientProfileState extends State<HumanPatientProfile> {
  final User? user = FirebaseAuth.instance.currentUser;

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
    if (user != null) {
      fetchProfileData(user!.uid);
      fetchDoctors();
    }
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
      final querySnapshot =
          await FirebaseFirestore.instance.collection('doctors').get();

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SAFE-SPACE'),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 2, 93, 98), // Teal color theme
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Global padding for the body
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: NetworkImage(
                            'https://placekitten.com/200/200'), // Temporary image
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.add,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patientName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Age: $age',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sex: $sex',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1),
              SizedBox(height: 16),
              GridView.count(
                padding: EdgeInsets.symmetric(vertical: 16),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildCard(
                    title: 'Online Consultations',
                    icon: Icons.video_call,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => OnlineConsultationPage()),
                      // );
                    },
                  ),
                  _buildCard(
                    title: 'Book Appointment',
                    icon: Icons.local_hospital,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookAppointmentPage()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Doctors',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HumanDoctorDetail(),
                          ),
                        );
                      },
                      child: Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(
                              255, 2, 93, 98), // Teal color theme
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: doctorCardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctorList.length,
                  itemBuilder: (context, index) {
                    final doctor = doctorList[index];
                    return _buildDoctorCard(
                      name: doctor['name'] ?? 'Unknown',
                      specialty:
                          doctor['specialization'] ?? 'Specialty Not Available',
                      experience: doctor['experience'] ?? '0',
                      height: doctorCardHeight,
                      width: doctorCardWidth,
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hospitals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: hospitalCardHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return _buildHospitalCard(
                      'Hospital ${index + 1}',
                      height: hospitalCardHeight,
                      width: hospitalCardWidth,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewProfileHumanScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AppointmentsPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        },
        items: [
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
            label: 'Menu',
          ),
        ],
        selectedItemColor:
            const Color.fromARGB(255, 2, 93, 98), // Teal color theme
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildCard(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 40,
                color:
                    const Color.fromARGB(255, 2, 93, 98)), // Teal color theme
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String experience,
    required double height,
    required double width,
  }) {
    return Card(
      margin: EdgeInsets.all(13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.person,
                size: 40,
                color:
                    const Color.fromARGB(255, 2, 93, 98)), // Teal color theme
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              specialty,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              '$experience Years Experience',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(
    String hospitalName, {
    required double height,
    required double width,
  }) {
    return Card(
      margin: EdgeInsets.all(13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital,
                size: 40,
                color:
                    const Color.fromARGB(255, 2, 93, 98)), // Teal color theme
            SizedBox(height: 8),
            Text(
              hospitalName,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
