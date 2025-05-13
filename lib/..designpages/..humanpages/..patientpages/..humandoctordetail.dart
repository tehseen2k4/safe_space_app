import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../doctorpages/humandoctorfulldetailpage.dart';

class HumanDoctorDetail extends StatefulWidget {
  @override
  _HumanDoctorDetailState createState() => _HumanDoctorDetailState();
}

class _HumanDoctorDetailState extends State<HumanDoctorDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedCategory = 'All'; // Initially show all doctors

  final List<Map<String, dynamic>> doctorList = [
    {
      'name': 'Dr. John Smith',
      'specialization': 'Cardiologist',
      'experience': '15',
      'rating': '4.8',
    },
    {
      'name': 'Dr. Sarah Johnson',
      'specialization': 'Dermatologist',
      'experience': '10',
      'rating': '4.9',
    },
    {
      'name': 'Dr. Michael Brown',
      'specialization': 'Neurologist',
      'experience': '12',
      'rating': '4.7',
    },
    {
      'name': 'Dr. Emily Davis',
      'specialization': 'Pediatrician',
      'experience': '8',
      'rating': '4.9',
    },
  ];

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
              backgroundColor: const Color(0xFF1976D2),
              child: Text(
                doctor['name'] != null ? doctor['name'][0].toUpperCase() : 'D',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2),
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
                          color: const Color(0xFF1976D2)),
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
                          color: const Color(0xFF1976D2)),
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
                        backgroundColor: const Color(0xFF1976D2),
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
                    ? const Color(0xFF1976D2)
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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Available Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 28 : 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        toolbarHeight: isDesktop ? 80 : 70,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : (isTablet ? 20 : 16),
              vertical: isDesktop ? 40 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(isDesktop),
                SizedBox(height: isDesktop ? 32 : 24),
                _buildFilterSection(isDesktop),
                SizedBox(height: isDesktop ? 32 : 24),
                _buildDoctorsList(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: isDesktop ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: isDesktop ? 28 : 24,
          ),
          SizedBox(width: isDesktop ? 16 : 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isDesktop ? 18 : 16,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(bool isDesktop) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All', true, isDesktop),
          SizedBox(width: isDesktop ? 16 : 12),
          _buildFilterChip('Cardiologist', false, isDesktop),
          SizedBox(width: isDesktop ? 16 : 12),
          _buildFilterChip('Dermatologist', false, isDesktop),
          SizedBox(width: isDesktop ? 16 : 12),
          _buildFilterChip('Neurologist', false, isDesktop),
          SizedBox(width: isDesktop ? 16 : 12),
          _buildFilterChip('Pediatrician', false, isDesktop),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDesktop) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[800],
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (bool selected) {
        // TODO: Implement filter selection
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1976D2),
      checkmarkColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 16 : 12,
        vertical: isDesktop ? 12 : 8,
      ),
    );
  }

  Widget _buildDoctorsList(bool isDesktop) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
        crossAxisSpacing: isDesktop ? 24 : 16,
        mainAxisSpacing: isDesktop ? 24 : 16,
        childAspectRatio: isDesktop ? 0.85 : 0.9,
      ),
      itemCount: doctorList.length,
      itemBuilder: (context, index) {
        final doctor = doctorList[index];
        return _buildDoctorCard(
          name: doctor['name'] ?? 'Unknown',
          specialty: doctor['specialization'] ?? 'Specialty Not Available',
          experience: doctor['experience'] ?? '0',
          rating: doctor['rating'] ?? '0.0',
          isDesktop: isDesktop,
        );
      },
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String experience,
    required String rating,
    required bool isDesktop,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isDesktop ? 200 : 160,
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: CircleAvatar(
                radius: isDesktop ? 60 : 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: isDesktop ? 60 : 50,
                  color: const Color(0xFF1976D2),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 20 : 18,
                  ),
                ),
                SizedBox(height: isDesktop ? 8 : 4),
                Text(
                  specialty,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: isDesktop ? 20 : 16,
                    ),
                    SizedBox(width: isDesktop ? 8 : 4),
                    Text(
                      rating,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: isDesktop ? 16 : 12),
                    Icon(
                      Icons.work,
                      color: Colors.grey[600],
                      size: isDesktop ? 20 : 16,
                    ),
                    SizedBox(width: isDesktop ? 8 : 4),
                    Text(
                      '$experience Years',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement book appointment
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isDesktop ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
