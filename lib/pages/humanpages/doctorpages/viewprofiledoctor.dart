import 'package:flutter/material.dart';
import 'package:safe_space_app/models/doctors_db.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/editprofiledoctor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: ViewProfileDoctorScreen(),
    );
  }
}

class ViewProfileDoctorScreen extends StatefulWidget {
  const ViewProfileDoctorScreen({super.key});

  @override
  State<ViewProfileDoctorScreen> createState() => _ViewProfileDoctorScreenState();
}

class _ViewProfileDoctorScreenState extends State<ViewProfileDoctorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorView(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No profile data found.'));
            }

            final doctor = snapshot.data!;
            return Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
                ),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: isDesktop ? 400 : 300,
                      pinned: true,
                      stretch: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const [
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                        ],
                        background: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: _buildHeaderSection(doctor, isDesktop),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildInfoSection(doctor, isDesktop),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> doctor, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Hero(
                tag: 'doctor_profile_${doctor['uid']}',
                child: Container(
                  width: isDesktop ? 160 : 120,
                  height: isDesktop ? 160 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/one.jpg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: isDesktop ? 24 : 20,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Hero(
            tag: 'doctor_name_${doctor['uid']}',
            child: Text(
              doctor['name'] ?? '',
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            doctor['specialization'] ?? '',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic> doctor, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
      child: Column(
        children: [
          SizedBox(height: isDesktop ? 30 : 20),
          _buildInfoCard(
            icon: Icons.person,
            title: 'Personal Information',
            children: [
              _buildInfoRow('Username', doctor['username'] ?? '', isDesktop),
              _buildInfoRow('Email', doctor['email'] ?? '', isDesktop),
              _buildInfoRow('Age', '${doctor['age'] ?? ''} years', isDesktop),
              _buildInfoRow('Sex', doctor['sex'] ?? '', isDesktop),
              _buildInfoRow('Phone Number', doctor['phonenumber'] ?? '', isDesktop),
            ],
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 30 : 20),
          _buildInfoCard(
            icon: Icons.medical_services,
            title: 'Professional Information',
            children: [
              _buildInfoRow('Qualification', doctor['qualification'] ?? '', isDesktop),
              _buildInfoRow('Experience', doctor['experience'] ?? '', isDesktop),
              _buildInfoRow('Doctor Type', doctor['doctorType'] ?? '', isDesktop),
              _buildInfoRow('Fees', '₹${doctor['fees'] ?? ''}', isDesktop),
            ],
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 30 : 20),
          _buildInfoCard(
            icon: Icons.business,
            title: 'Clinic Information',
            children: [
              _buildInfoRow('Clinic Name', doctor['clinicName'] ?? '', isDesktop),
              _buildInfoRow('Clinic Contact', doctor['contactNumberClinic'] ?? '', isDesktop),
            ],
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 30 : 20),
          _buildInfoCard(
            icon: Icons.info,
            title: 'About',
            children: [
              Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: Text(
                  doctor['bio'] ?? '',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
            ],
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 40 : 30),
          ElevatedButton(
            onPressed: () async {
              try {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditPageDoctor()),
                );
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error navigating to edit page: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 40,
                vertical: isDesktop ? 20 : 15,
              ),
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: isDesktop ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 40 : 30),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
    required bool isDesktop,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Padding(
            padding: EdgeInsets.all(isDesktop ? 24 : 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.teal,
                  size: isDesktop ? 32 : 24,
                ),
                SizedBox(width: isDesktop ? 16 : 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 16,
        vertical: isDesktop ? 16 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 40 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isDesktop ? 80 : 60,
              color: Colors.red[400],
            ),
            SizedBox(height: isDesktop ? 30 : 20),
            Text(
              'Error loading profile: $error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: isDesktop ? 20 : 16,
              ),
            ),
            SizedBox(height: isDesktop ? 40 : 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditPageDoctor()),
                  );
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error navigating to edit page: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 60 : 40,
                  vertical: isDesktop ? 20 : 15,
                ),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create Profile',
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Profile not found');
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}
