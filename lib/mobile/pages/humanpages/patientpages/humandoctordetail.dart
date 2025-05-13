import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'humandoctorfulldetailpage.dart';

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
      QuerySnapshot snapshot = await _firestore
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Human')
          .get();
      
      print("Number of human doctors found: ${snapshot.docs.length}");
      
      if (snapshot.docs.isEmpty) {
        // If no doctors found with type 'Human', let's check all doctors
        final allDoctors = await _firestore.collection('doctors').get();
        print("Total number of doctors in database: ${allDoctors.docs.length}");
        print("First doctor data (if any): ${allDoctors.docs.isNotEmpty ? allDoctors.docs.first.data() : 'No doctors found'}");
      }

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
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
              backgroundColor: Colors.teal.withOpacity(0.1),
              child: Text(
                doctor['name'] != null ? doctor['name'][0].toUpperCase() : 'D',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? 'Doctor Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.medical_services, color: Colors.teal),
                      const SizedBox(width: 8.0),
                      Text(
                        doctor['specialization'] ?? 'Specialization',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.teal),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          doctor['clinicName'] ?? 'Clinic Name',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailPage(
                              doctor: doctor,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info, color: Colors.white),
                      label: const Text(
                        'View Details',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
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
      height: 50,
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: selectedCategory == category
                    ? Colors.teal
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Available Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16.0),
          buildCategorySelection(),
          const SizedBox(height: 16.0),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error fetching doctor data.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No doctors available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                  );
                } else {
                  final doctors = snapshot.data!.where((doctor) {
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
