import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:safe_space_app/web/pages/patient/humanpages/human_patient_profile_page.dart';
import 'package:safe_space_app/web/pages/auth/auth_selection_page.dart';
import 'package:safe_space_app/web/pages/patient/humanpages/human_patient_settings_page.dart';
import 'package:safe_space_app/web/pages/patient/humanpages/edit_human_patient_profile_page.dart';

class HumanPatientDashboard extends StatefulWidget {
  const HumanPatientDashboard({Key? key}) : super(key: key);

  @override
  State<HumanPatientDashboard> createState() => _HumanPatientDashboardState();
}

class _HumanPatientDashboardState extends State<HumanPatientDashboard> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  String _selectedNavItem = 'home';
  bool _isSidebarCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchPatientData() async {
    try {
      if (user == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
            .collection('humanpatients')
          .where('uid', isEqualTo: user!.uid)
            .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Patient profile not found');
      }

      return querySnapshot.docs.first.data();
    } catch (e) {
      print('Error fetching patient data: $e');
      rethrow;
    }
  }

  String _getPageTitle() {
    switch (_selectedNavItem) {
      case 'home':
        return 'Dashboard';
      case 'profile':
        return 'Profile';
      case 'edit_profile':
        return 'Edit Profile';
      case 'appointments':
        return 'My Appointments';
      case 'doctors':
        return 'Find Doctors';
      case 'messages':
        return 'Messages';
      case 'settings':
        return 'Settings';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: _isSidebarCollapsed ? 80 : 250,
      color: Colors.white,
      child: Column(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: _isSidebarCollapsed ? 20 : 40,
                  backgroundColor: Colors.teal[100],
                  child: const Icon(Icons.person, color: Colors.teal),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(height: 16),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _fetchPatientData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!['name'] ?? 'Patient',
                          style: const TextStyle(
                            fontSize: 18,
                              fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
                      return const Text('Loading...');
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
                // Navigation Items
                Expanded(
                  child: ListView(
              padding: EdgeInsets.zero,
                    children: [
                      _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: _selectedNavItem == 'home',
                  onTap: () => _updateSelectedItem('home'),
                      ),
                      _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: _selectedNavItem == 'profile',
                  onTap: () => _updateSelectedItem('profile'),
                      ),
                      _buildNavItem(
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  isSelected: _selectedNavItem == 'appointments',
                  onTap: () => _updateSelectedItem('appointments'),
                      ),
                      _buildNavItem(
                  icon: Icons.medical_services,
                  label: 'Find Doctors',
                  isSelected: _selectedNavItem == 'doctors',
                  onTap: () => _updateSelectedItem('doctors'),
                      ),
                      _buildNavItem(
                  icon: Icons.message,
                  label: 'Messages',
                  isSelected: _selectedNavItem == 'messages',
                  onTap: () => _updateSelectedItem('messages'),
                      ),
                      _buildNavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: _selectedNavItem == 'settings',
                  onTap: () => _updateSelectedItem('settings'),
                ),
              ],
            ),
          ),
          // Collapse Button
                      IconButton(
            icon: Icon(_isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _isSidebarCollapsed = !_isSidebarCollapsed;
                          });
                        },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
            icon,
            color: isSelected ? Colors.teal : Colors.grey[600],
          ),
      title: _isSidebarCollapsed
          ? null
          : Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.teal : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
      selected: isSelected,
      onTap: onTap,
      tileColor: isSelected ? Colors.teal.withOpacity(0.1) : null,
    );
  }

  void _updateSelectedItem(String item) {
    setState(() {
      _selectedNavItem = item;
    });
    _animationController.forward(from: 0.0);
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPatientData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final patientData = snapshot.data!;

    switch (_selectedNavItem) {
      case 'home':
              return _buildHomeContent(patientData);
            case 'profile':
              return HumanPatientProfilePage(
                patientData: patientData,
                onEditProfile: () => _updateSelectedItem('edit_profile'),
              );
            case 'edit_profile':
              return EditHumanPatientProfilePage(
                initialData: patientData,
                onSave: () {
                  _updateSelectedItem('profile');
                },
              );
      case 'appointments':
              return const Center(child: Text('Appointments Page - Coming Soon'));
      case 'doctors':
              return const Center(child: Text('Find Doctors Page - Coming Soon'));
      case 'messages':
              return const Center(child: Text('Messages Page - Coming Soon'));
            case 'settings':
              return const HumanPatientSettingsPage();
      default:
              return _buildHomeContent(patientData);
          }
        },
      ),
    );
  }

  Widget _buildHomeContent(Map<String, dynamic> patientData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal[100],
                  child: const Icon(Icons.person, size: 40, color: Colors.teal),
                ),
                const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                        'Welcome back, ${patientData['name'] ?? 'Patient'}!',
                  style: const TextStyle(
                          fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                        'Here\'s your health overview',
                  style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.calendar_today,
                  title: 'Upcoming Appointments',
                  value: '0',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.medical_services,
                  title: 'Active Prescriptions',
                  value: '0',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.history,
                  title: 'Past Consultations',
                  value: '0',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Container(
        padding: const EdgeInsets.all(24),
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
            const Text(
                  'Recent Activity',
              style: TextStyle(
                    fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'No recent activity',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Icon(
            icon,
            color: color,
            size: 32,
              ),
              const SizedBox(height: 16),
                  Text(
            value,
                    style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
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
            child: Column(
      children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                              Text(
                        _getPageTitle(),
                                style: const TextStyle(
                          fontSize: 24,
                                  fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications),
                      onPressed: () {
                          // TODO: Implement notifications
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: _buildMainContent(),
                    ),
                  ],
                ),
          ),
        ],
        ),
    );
  }
} 