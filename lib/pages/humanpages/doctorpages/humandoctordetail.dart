import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctordetailpage.dart';

class HumanDoctorDetail extends StatefulWidget {
  @override
  _HumanDoctorDetailState createState() => _HumanDoctorDetailState();
}

class _HumanDoctorDetailState extends State<HumanDoctorDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'All'; // Initially show all doctors

  // Function to fetch doctors from Firestore
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('doctors').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching doctors: $e");
      return [];
    }
  }

  // Function to build a doctor card
  Widget buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color.fromARGB(255, 172, 209, 200),
              child: Text(
                doctor['name'] != null ? doctor['name'][0].toUpperCase() : 'D',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 2, 93, 98),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? 'Doctor Name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.medical_services,
                          color: const Color.fromARGB(255, 2, 93, 98)),
                      SizedBox(width: 8.0),
                      Text(
                        doctor['specialization'] ?? 'Specialization',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: const Color.fromARGB(255, 2, 93, 98)),
                      SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          doctor['clinicName'] ?? 'Clinic Name',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to DoctorDetailPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailPage(
                              doctor: doctor,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.info, color: Colors.white),
                      label: Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the category selection
  Widget buildCategorySelection() {
    List<String> categories = [
      'All',
      'Psychiatrist',
      'Cardiologist',
      'Dermatologist',
      'Neurologist',
      'Pediatrician',
      'Orthopedic',
      'Gynecologist',
      'Radiologist',
    ];

    return Container(
      height: 50, // Adjust height to make it more visible
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: selectedCategory == category
                    ? const Color.fromARGB(255, 2, 93, 98)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedCategory == category
                        ? Colors.white
                        : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctor Details',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0),
          buildCategorySelection(), // Display category selection
          SizedBox(height: 16.0),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error fetching doctor data.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No doctors available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                } else {
                  final doctors = snapshot.data!.where((doctor) {
                    // Ensure specialization field is not null or empty
                    final specialization = doctor['specialization'];
                    return selectedCategory == 'All' ||
                        (specialization != null &&
                            specialization == selectedCategory);
                  }).toList();

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      return buildDoctorCard(doctors[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
