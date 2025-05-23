import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'petdoctorfulldetailpage.dart';

class PetDoctorDetail extends StatefulWidget {
  @override
  _PetDoctorDetailState createState() => _PetDoctorDetailState();
}

class _PetDoctorDetailState extends State<PetDoctorDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'All';

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('doctors')
          .where('doctorType', isEqualTo: 'Veterinary')
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching doctors: $e");
      return [];
    }
  }

  Widget buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFE17652).withOpacity(0.1),
              child: Text(
                doctor['name'] != null ? doctor['name'][0].toUpperCase() : 'V',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE17652),
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
                      const Icon(
                        Icons.medical_services,
                        color: Color(0xFFE17652),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        doctor['specialization'] ?? 'Specialization',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFE17652),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text(
                          doctor['clinicName'] ?? 'Clinic Name',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Color(0xFFE17652),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        doctor['contactNumberClinic'] ?? 'Contact Not Available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: Color(0xFFE17652),
                        size: 20,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Fees: \$${doctor['fees']?.toString() ?? 'Not specified'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
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
                            builder: (context) => PetDoctorFullDetailPage(
                              doctor: doctor,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info, color: Colors.white),
                      label: const Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE17652),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
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

  Widget buildCategorySelection() {
    List<String> categories = [
      'All',
      'General Veterinary',
      'Surgery',
      'Dermatology',
      'Internal Medicine',
      'Emergency Care',
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    ? const Color(0xFFE17652)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  if (selectedCategory == category)
                    BoxShadow(
                      color: const Color(0xFFE17652).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
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
          'Veterinary Doctors',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE17652),
        foregroundColor: Colors.white,
        elevation: 0,
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
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE17652),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error fetching doctor data.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.pets,
                          color: Color(0xFFE17652),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No veterinary doctors available.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
                    padding: const EdgeInsets.symmetric(vertical: 8),
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