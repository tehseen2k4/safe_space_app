import 'package:flutter/material.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/humandoctorappointmentlistpage.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/petdoctorappointmentlistpage.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/viewprofiledoctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/appointmentdetailpage.dart';

class Doctorlogin extends StatefulWidget {
  const Doctorlogin({super.key});

  @override
  State<Doctorlogin> createState() => _DoctorloginState();
}

class _DoctorloginState extends State<Doctorlogin> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _currentIndex = 0; // Track the current index for BottomNavigationBar

  String doctorName = "Doctor Name";
  String specialization = "**";
  String qualification = "***";
  String doctorType = '';
  Future<List>? _appointmentsFuture;

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
          .collection('doctors')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        setState(() {
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
      // Error fetching profile; default values remain
    }
  }

  void _onBottomNavTap(int index) async {
    setState(() {
      _currentIndex = index;
    });

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
    } else if (index == 1) {
      if (doctorType == "Human") {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Humandoctorappointmentlistpage(),
          ),
        );
        if (user != null) {
          fetchProfileData(user!.uid);
        }
      } else if (doctorType == "Veterinary") {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDoctorAppointmentsListPage(),
          ),
        );
        if (user != null) {
          fetchProfileData(user!.uid);
        }
      }
    }
  }

  Future<List<PetAppointmentDb>> _fetchPetAppointments() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('petappointments')
          .where('uid', isEqualTo: user.uid)
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
        backgroundColor: Colors.white, // Background color
        appBar: AppBar(
          title: const Text(
            'SAFE-SPACE',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ), // Make title bold
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.teal,
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          toolbarHeight: 70,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.black,
              height: 1,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor's Profile Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar(
                    //   radius: 50,
                    //   backgroundColor: Colors.grey.shade200,
                    //   child: IconButton(
                    //     icon: const Icon(Icons.add,
                    //         size: 30, color: Color.fromARGB(255, 0, 0, 0)),
                    //     onPressed: () {},
                    //   ),
                    // ),
                    Column(
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
                    ),
                    SizedBox(width: 19),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. ${doctorName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          specialization,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey),
                        ),
                        SizedBox(height: 6),
                        Text(
                          qualification,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Stars for Rating
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star_border, color: Colors.amber, size: 20),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(color: Colors.teal, thickness: 1),

                // // Appointments Section
                // const Text(
                //   'Appointments',
                //   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                // ),
                // const SizedBox(height: 10),
                // SizedBox(
                //   height: 180, // Adjust height to make containers bigger
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: 4,
                //     itemBuilder: (context, index) {
                //       return Container(
                //         width: 180, // Adjust width for bigger containers
                //         margin: const EdgeInsets.only(right: 10),
                //         decoration: BoxDecoration(
                //           color: Colors.grey.shade200,
                //           borderRadius: BorderRadius.circular(8),
                //         ),
                //         child: Center(child: Text('Appointment ${index + 1}')),
                //       );
                //     },
                //   ),
                // ),

                // Inside the Appointments Section
                const Text(
                  'Pending Appointments',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220, // Adjust height for the cards
                  child: FutureBuilder<List>(
                    future: _appointmentsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child:
                              CircularProgressIndicator(), // Show loading indicator
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error fetching appointments'),
                        );
                      } else if (snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No appointments found'),
                        );
                      }

                      final appointments = snapshot.data!; // Use the fetched list

                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return _buildCard(appointment, context);
                        },
                      );
                    },
                  ),
                ),

                // Reviews Section
                const SizedBox(height: 20),
                const Text(
                  'Reviews',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height:
                      200, // Adjust height to accommodate ratings and better layout
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // Number of reviews
                    itemBuilder: (context, index) {
                      // Hardcoded fake reviews and ratings
                      final fakeReviews = [
                        {
                          "review":
                              "He is fantastic! He truly cares and helped me manage my pain effectively.",
                          "rating": 5
                        },
                        {
                          "review":
                              "Fantastic! He truly cares and helped me manage my pain effectively.",
                          "rating": 4
                        },
                        {
                          "review":
                              "This Doc. is the best! listens carefully and explains everything clearly.",
                          "rating": 5
                        },
                        {
                          "review":
                              "He is a great doctor. His expertise and care are unmatched!",
                          "rating": 4
                        },
                        {
                          "review":
                              "He is very welcoming, and his care is excellent. Highly recommend!",
                          "rating": 5
                        },
                      ];

                      // Safely fetch the review and cast fields
                      final review = fakeReviews[index];
                      final String reviewText = review["review"] as String;
                      final int rating = review["rating"] as int;

                      return Container(
                        width: 220, // Adjust width for better content spacing
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(
                            12), // Add padding inside the box
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Reviewer Name Placeholder
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey.shade200,
                                  child: const Icon(Icons.person,
                                      size: 18, color: Colors.teal),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Patient ${index + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.teal),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Star Ratings
                            Row(
                              children: List.generate(
                                rating,
                                (starIndex) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              )..addAll(
                                  List.generate(
                                    5 - rating,
                                    (emptyStarIndex) => const Icon(
                                      Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                  ),
                                ),
                            ),
                            Divider(
                                thickness: 1,
                                color: Colors.teal.shade200,
                                height: 8),
                            const SizedBox(height: 10),

                            // Review Text
                            Expanded(
                              child: Text(
                                reviewText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            // Date Placeholder (Optional)
                            const SizedBox(height: 10),
                            Text(
                              "Posted on ${DateTime.now().subtract(Duration(days: index * 2)).toLocal().toString().split(' ')[0]}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal,
          currentIndex: _currentIndex, // Highlight the current tab
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
      ),
    );
  }

  Widget _buildCard(HumanAppointmentDb appointment, BuildContext context) {
    return Container(
      height: 200,
      width: 220, // Adjust width for better content spacing
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12), // Add padding inside the box
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Appointment ID
            Text(
              'ID: ${appointment.appointmentId}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Divider(thickness: 1, color: Colors.teal.shade200, height: 8),
            // Username
            Row(
              children: [
                Icon(Icons.person, color: Colors.teal, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.username,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Timeslot
            Row(
              children: [
                Icon(Icons.watch_later, color: Colors.teal, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.timeslot,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Reason for Visit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.description, color: Colors.teal, size: 14),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    appointment.reasonforvisit,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // View Details Button
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentDetailsPage(
                        appointment: appointment,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(60, 20),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
