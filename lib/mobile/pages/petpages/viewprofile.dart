import 'package:flutter/material.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:safe_space_app/mobile/pages/petpages/editprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile View',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ViewProfileScreen(),
    );
  }
}

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: FutureBuilder<PetpatientDb>(
          future: _fetchProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE17652),
                ),
              );
            } else if (snapshot.hasError) {
              return _buildErrorView(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No profile data found.'));
            }

            final pet = snapshot.data!;
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
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
                      child: _buildHeaderSection(pet),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildInfoSection(pet),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(PetpatientDb pet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE17652),
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
                tag: 'pet_profile_${pet.uid}',
                child: Container(
                  width: 120,
                  height: 120,
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
          Hero(
            tag: 'pet_name_${pet.uid}',
            child: Text(
              pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${pet.type} - ${pet.breed}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoSection(PetpatientDb pet) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.pets,
          title: 'Basic Information',
          children: [
            _buildInfoRow('Type', pet.type),
            _buildInfoRow('Breed', pet.breed),
            _buildInfoRow('Age', '${pet.age} years'),
            _buildInfoRow('Gender', pet.sex),
            _buildInfoRow('Date of Birth', '${pet.dateOfBirth.day}/${pet.dateOfBirth.month}/${pet.dateOfBirth.year}'),
            _buildInfoRow('Weight', '${pet.weight} kg'),
            _buildInfoRow('Neuter Status', pet.neuterStatus),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.person,
          title: 'Owner Information',
          children: [
            _buildInfoRow('Owner Name', pet.ownerName),
            _buildInfoRow('Owner Phone', pet.ownerPhone),
            _buildInfoRow('Emergency Contact', pet.emergencyContact),
            _buildInfoRow('Email', pet.email),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          icon: Icons.medical_services_outlined,
          title: 'Medical Information',
          children: [
            _buildInfoRow('Last Vaccination', '${pet.lastVaccination.day}/${pet.lastVaccination.month}/${pet.lastVaccination.year}'),
            _buildInfoRow('Training Status', pet.trainingStatus),
            _buildInfoRow('Allergies', pet.allergies.isEmpty ? 'None' : pet.allergies.join(', ')),
            _buildInfoRow('Special Needs', pet.specialNeeds.isEmpty ? 'None' : pet.specialNeeds.join(', ')),
            _buildInfoRow('Dietary Requirements', pet.dietaryRequirements.isEmpty ? 'None' : pet.dietaryRequirements.join(', ')),
            _buildInfoRow('Grooming Needs', pet.groomingNeeds.isEmpty ? 'None' : pet.groomingNeeds.join(', ')),
          ],
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            try {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditPagePet()),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 15,
            ),
            backgroundColor: const Color(0xFFE17652),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFE17652),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE17652),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE17652),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Profile not found. Please contact support.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: const Color(0xFFE17652),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 16,
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

  Future<PetpatientDb> _fetchProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('uid', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Profile not found');
      }

      return PetpatientDb.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }
}
