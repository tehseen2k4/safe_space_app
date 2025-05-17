import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_profile_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_settings_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/edit_pet_patient_profile_page.dart';
import 'package:safe_space_app/models/petpatient_db.dart';

class PetPatientDashboard extends StatefulWidget {
  const PetPatientDashboard({Key? key}) : super(key: key);

  @override
  State<PetPatientDashboard> createState() => _PetPatientDashboardState();
}

class _PetPatientDashboardState extends State<PetPatientDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedNavigationItem = 'dashboard';
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPatientData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('pets').doc(user.uid);
        final docSnapshot = await docRef.get();
        
        if (docSnapshot.exists) {
          setState(() {
            _patientData = docSnapshot.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _patientData = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patient data: $e')),
        );
      }
    }
  }

  void _updateSelectedItem(String item) {
      setState(() {
      _selectedNavigationItem = item;
    });
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
            color: Colors.white,
            child: Column(
              children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.pets, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            _patientData?['name'] ?? 'Pet Name',
            style: const TextStyle(
              fontSize: 18,
                              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _patientData?['species'] ?? 'Species',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildNavigationItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            item: 'dashboard',
          ),
          _buildNavigationItem(
            icon: Icons.person,
            title: 'Profile',
            item: 'profile',
          ),
          _buildNavigationItem(
            icon: Icons.settings,
            title: 'Settings',
            item: 'settings',
                      ),
                      const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String item,
  }) {
    final isSelected = _selectedNavigationItem == item;
    return ListTile(
      leading: Icon(
            icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => _updateSelectedItem(item),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (_selectedNavigationItem) {
      case 'dashboard':
        return _buildDashboard();
      case 'profile':
        return PetPatientProfilePage(
          onEditProfile: () => _updateSelectedItem('edit_profile'),
        );
      case 'edit_profile':
        return EditPetPatientProfilePage(
          onSave: () => _updateSelectedItem('profile'),
        );
      case 'settings':
        return const PetPatientSettingsPage();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 24,
                    fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard(
          title: 'Upcoming Appointments',
          value: '0',
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Prescriptions',
          value: '0',
          icon: Icons.medical_services,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Medical Records',
          value: '0',
          icon: Icons.folder,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('No Recent Activity'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
                  Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _buildMainContent(),
            ),
          ),
        ],
      ),
    );
  }
} 