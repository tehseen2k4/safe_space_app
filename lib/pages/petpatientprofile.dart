import 'package:flutter/material.dart';
import 'package:safe_space/pages/patientpages/petappointmentlistpage.dart';
import 'package:safe_space/pages/viewprofile.dart';
import 'package:safe_space/pages/patientpages/appointmentbooking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space/pages/patientpages/petappointmentbooking.dart';

class Petpatientprofile extends StatefulWidget {
  @override
  _PetpatientprofileState createState() => _PetpatientprofileState();
}

class _PetpatientprofileState extends State<Petpatientprofile> {
  final User? user = FirebaseAuth.instance.currentUser;
  final double hospitalCardHeight =
      200; // You can change this value to any height you want
  final double hospitalCardWidth = 200; // Set your desired width

  String petName = "Pet Name";
  String age = "**";
  String sex = "***";

  @override
  void initState() {
    super.initState();
    if (user != null) {
      fetchProfileData(user!.uid);
    }
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
      // Error fetching profile; default values remain
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        title: Text('SAFE-SPACE'),
        centerTitle: true,
        backgroundColor:
            const Color.fromARGB(255, 225, 118, 82), // Teal color theme
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Age: $age'),
                    Text('Sex: $sex'),
                  ],
                ),
              ],
            ),
          ),
          Divider(thickness: 1),
          Expanded(
            child: Column(
              children: [
                GridView.count(
                  padding: const EdgeInsets.all(16.0),
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
                              builder: (context) => BookAppointmentPetPage()),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Hospitals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                        width: 150,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Highlight the current tab (Home as default)
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewProfileScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PetAppointmentsListPage()),
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
            const Color.fromARGB(255, 225, 118, 82), // Teal color theme
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
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 40, color: const Color.fromARGB(255, 225, 118, 82)),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard(String hospitalName,
      {required double height, required double width}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        child: Container(
          height: height,
          width: width,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital,
                size: 40,
                color: const Color.fromARGB(255, 225, 118, 82),
              ),
              SizedBox(height: 8),
              Text(
                hospitalName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
