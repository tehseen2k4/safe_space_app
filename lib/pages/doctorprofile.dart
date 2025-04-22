import 'package:flutter/material.dart';
import 'package:safe_space/models/humanappointment_db.dart';
import 'package:safe_space/models/petappointment_db.dart';
import 'package:safe_space/pages/doctorpages/humandoctorappointmentlistpage.dart';
import 'package:safe_space/pages/doctorpages/petdoctorappointmentlistpage.dart';
import 'package:safe_space/pages/doctorpages/viewprofiledoctor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space/pages/patientpages/appointmentdetailpage.dart';

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
        });
      }
    } catch (e) {
      // Error fetching profile; default values remain
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 3) {
      // Navigate to the "More" screen when tapped
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewProfileDoctorScreen(),
        ),
      );
    } else if (index == 1) {
      if (doctorType == "Human") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Humandoctorappointmentlistpage(),
          ),
        );
      } else if (doctorType == "Veterinary") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDoctorAppointmentsListPage(),
          ),
        );
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
    return Scaffold(
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
                  future: doctorType == "Human"
                      ? _fetchHumanAppointments()
                      : _fetchPetAppointments(),
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



              // // Reviews Section
              // const Text(
              //   'Reviews',
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
              //         child: Center(child: Text('Review ${index + 1}')),
              //       );
              //     },
              //   ),
              // ),
              // const SizedBox(height: 20),




// import 'package:flutter/material.dart';
// import 'package:safe_space/pages/doctorpages/viewprofiledoctor.dart';

// class Doctorlogin extends StatelessWidget {
//   const Doctorlogin({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Background color
//       appBar: AppBar(
//         title: const Text(
//           'SAFE-SPACE',
//           style: TextStyle(fontWeight: FontWeight.bold), // Make title bold
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         toolbarHeight: 70,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(
//             color: Colors.black,
//             height: 1,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         // Wrap the body with SingleChildScrollView
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Doctor's Profile Section
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.grey.shade200,
//                     child: IconButton(
//                       icon:
//                           const Icon(Icons.add, size: 30, color: Colors.black),
//                       onPressed: () {},
//                     ),
//                   ),
//                   const SizedBox(width: 19),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: const [
//                       Text(
//                         'Dr. Professor Vaneeza',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 20,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         'Surgeon',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 18),
//                       ),
//                       SizedBox(height: 6),
//                       Text(
//                         'Mbbs(Pb), Phd(AFPGM)',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 17),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),

//               // Stars for Rating
//               const Row(
//                 children: [
//                   Icon(Icons.star, color: Colors.yellow, size: 20),
//                   Icon(Icons.star, color: Colors.yellow, size: 20),
//                   Icon(Icons.star, color: Colors.yellow, size: 20),
//                   Icon(Icons.star, color: Colors.yellow, size: 20),
//                   Icon(Icons.star_border, color: Colors.yellow, size: 20),
//                 ],
//               ),
//               const SizedBox(height: 18),
//               const Divider(color: Colors.black, thickness: 1),

//               // Reviews Section
//               const Text(
//                 'Reviews',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 180, // Adjust height to make containers bigger
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 4,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       width: 180, // Adjust width for bigger containers
//                       margin: const EdgeInsets.only(right: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(child: Text('Review ${index + 1}')),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Appointments Section
//               const Text(
//                 'Appointments',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 180, // Adjust height to make containers bigger
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 4,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       width: 180, // Adjust width for bigger containers
//                       margin: const EdgeInsets.only(right: 10),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade200,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Center(child: Text('Appointment ${index + 1}')),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       // Bottom Navigation Bar
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Color.fromARGB(255, 255, 255, 255),
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.black,
//         currentIndex: 0, // Highlight the current tab (Home as default)
//         onTap: (index) {
//           if (index == 3) {
//             // Check if the Menu icon is tapped
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => ViewProfileDoctorScreen()),
//             );
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: 'Calendar',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.mail),
//             label: 'Messages',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.menu),
//             label: 'More',
//           ),
//         ],
//       ),
//     );
//   }
// }
