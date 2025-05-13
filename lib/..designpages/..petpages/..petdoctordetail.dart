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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: isDesktop ? 24.0 : (isTablet ? 16.0 : 8.0),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: isDesktop ? 50 : 40,
              backgroundColor: const Color.fromARGB(255, 225, 118, 82),
              child: Text(
                doctor['name'] != null ? doctor['name'][0].toUpperCase() : 'V',
                style: TextStyle(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: isDesktop ? 24.0 : 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['name'] ?? 'Doctor Name',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12.0 : 8.0),
                  Row(
                    children: [
                      Icon(Icons.medical_services,
                          color: const Color.fromARGB(255, 225, 118, 82),
                          size: isDesktop ? 24 : 20),
                      SizedBox(width: isDesktop ? 12.0 : 8.0),
                      Text(
                        doctor['specialization'] ?? 'Specialization',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 12.0 : 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: const Color.fromARGB(255, 225, 118, 82),
                          size: isDesktop ? 24 : 20),
                      SizedBox(width: isDesktop ? 12.0 : 8.0),
                      Flexible(
                        child: Text(
                          doctor['clinicName'] ?? 'Clinic Name',
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 12.0 : 8.0),
                  Row(
                    children: [
                      Icon(Icons.phone,
                          color: const Color.fromARGB(255, 225, 118, 82),
                          size: isDesktop ? 24 : 20),
                      SizedBox(width: isDesktop ? 12.0 : 8.0),
                      Text(
                        doctor['contactNumberClinic'] ?? 'Contact Not Available',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 12.0 : 8.0),
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          color: const Color.fromARGB(255, 225, 118, 82),
                          size: isDesktop ? 24 : 20),
                      SizedBox(width: isDesktop ? 12.0 : 8.0),
                      Text(
                        'Fees: \$${doctor['fees']?.toString() ?? 'Not specified'}',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isDesktop ? 20.0 : 16.0),
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
                      icon: Icon(Icons.info, color: Colors.white),
                      label: Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isDesktop ? 16 : 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                          vertical: isDesktop ? 16 : 12,
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    List<String> categories = [
      'All',
      'General Veterinary',
      'Surgery',
      'Dermatology',
      'Internal Medicine',
      'Emergency Care',
    ];

    return Container(
      height: isDesktop ? 60 : 50,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : (isTablet ? 16 : 8),
      ),
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
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24 : 20,
                vertical: isDesktop ? 12 : 10,
              ),
              margin: EdgeInsets.only(right: isDesktop ? 16 : 10),
              decoration: BoxDecoration(
                color: selectedCategory == category
                    ? const Color.fromARGB(255, 225, 118, 82)
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
                    fontSize: isDesktop ? 18 : 16,
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Veterinary Doctors',
          style: TextStyle(
            color: Colors.white,
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 225, 118, 82),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
        ),
        child: Column(
          children: [
            SizedBox(height: isDesktop ? 24.0 : 16.0),
            buildCategorySelection(),
            SizedBox(height: isDesktop ? 24.0 : 16.0),
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
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No veterinary doctors available.',
                        style: TextStyle(
                          fontSize: isDesktop ? 20 : 18,
                          color: Colors.grey,
                        ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 24 : (isTablet ? 16 : 8),
                        vertical: isDesktop ? 16 : 8,
                      ),
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
      ),
    );
  }
} 