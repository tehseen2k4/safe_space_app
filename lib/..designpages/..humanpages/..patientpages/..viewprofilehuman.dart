import 'package:flutter/material.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/editprofilehuman.dart';
import 'package:safe_space_app/models/patients_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/humanpatientprofile.dart';

class ViewProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
      home: ViewProfileHumanScreen(),
    );
  }
}

class ViewProfileHumanScreen extends StatefulWidget {
  const ViewProfileHumanScreen({super.key});

  @override
  _ViewProfileHumanScreenState createState() => _ViewProfileHumanScreenState();
}

class _ViewProfileHumanScreenState extends State<ViewProfileHumanScreen> with SingleTickerProviderStateMixin {
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

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HumanPatientProfile()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: FutureBuilder<PatientsDb>(
            future: _fetchProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return _buildErrorView(snapshot.error.toString());
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No profile data found.'));
              }

              final patient = snapshot.data!;
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: isDesktop ? 400 : (isTablet ? 350 : 300),
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
                        child: _buildHeaderSection(patient, isDesktop),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
                      ),
                      child: _buildInfoSection(patient, isDesktop),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(PatientsDb patient, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 5),
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
                tag: 'human_profile_${patient.uid}',
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
            ],
          ),
          const SizedBox(height: 20),
          Text(
            patient.name,
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            patient.email,
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoSection(PatientsDb patient, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
      child: Column(
        children: [
          SizedBox(height: isDesktop ? 40 : 20),
          _buildInfoCard(
            icon: Icons.person,
            title: 'Personal Information',
            children: [
              _buildInfoRow('Age', '${patient.age} years', isDesktop),
              _buildInfoRow('Sex', patient.sex, isDesktop),
              _buildInfoRow('Blood Group', patient.bloodgroup, isDesktop),
            ],
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 30 : 20),
          _buildInfoCard(
            icon: Icons.email,
            title: 'Contact Information',
            children: [
              _buildInfoRow('Email', patient.email, isDesktop),
            ],
            isDesktop: isDesktop,
          ),
          SizedBox(height: isDesktop ? 40 : 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EditPageHuman()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 40,
                vertical: isDesktop ? 20 : 15,
              ),
              backgroundColor: const Color(0xFF1976D2),
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
                  color: const Color(0xFF1976D2),
                  size: isDesktop ? 32 : 24,
                ),
                SizedBox(width: isDesktop ? 16 : 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1976D2),
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
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1976D2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 800 : (isTablet ? 600 : screenSize.width),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : (isTablet ? 20 : 20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EditPageHuman()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 40,
                    vertical: isDesktop ? 20 : 15,
                  ),
                  backgroundColor: const Color(0xFF1976D2),
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
      ),
    );
  }

  Future<PatientsDb> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('humanpatients')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Profile not found');
      }

      return PatientsDb.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}
