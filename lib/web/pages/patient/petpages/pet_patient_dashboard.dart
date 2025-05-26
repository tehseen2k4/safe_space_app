import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_profile_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_settings_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/edit_pet_patient_profile_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_appointments_page.dart';
import 'package:safe_space_app/models/petpatient_db.dart';
import 'package:safe_space_app/web/pages/web_home_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_chat_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_book_appointment_page.dart';

class PetPatientDashboard extends StatefulWidget {
  const PetPatientDashboard({Key? key}) : super(key: key);

  @override
  State<PetPatientDashboard> createState() => _PetPatientDashboardState();
}

class _PetPatientDashboardState extends State<PetPatientDashboard> with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  String _selectedNavItem = 'home';
  bool _isSidebarCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;

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
    _loadPatientData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientData() async {
    setState(() => _isLoading = true);
    try {
      if (user != null) {
        final docRef = FirebaseFirestore.instance.collection('pets').doc(user!.uid);
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

  String _getPageTitle() {
    switch (_selectedNavItem) {
      case 'home':
        return 'Dashboard';
      case 'profile':
        return 'Profile';
      case 'edit_profile':
        return 'Edit Profile';
      case 'book_appointment':
        return 'Book an Appointment';
      case 'appointments':
        return 'My Appointments';
      case 'vets':
        return 'Find Vets';
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
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: _isSidebarCollapsed ? 20 : 40,
                  backgroundColor: Colors.teal[100],
                  child: const Icon(Icons.pets, color: Colors.teal),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(height: 16),
                  Text(
                    _patientData?['name'] ?? 'Pet Name',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _patientData?['species'] ?? 'Species',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
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
                  icon: Icons.add_circle_outline,
                  label: 'Book an Appointment',
                  isSelected: _selectedNavItem == 'book_appointment',
                  onTap: () => _updateSelectedItem('book_appointment'),
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
                  label: 'Appointments',
                  isSelected: _selectedNavItem == 'appointments',
                  onTap: () => _updateSelectedItem('appointments'),
                ),
                _buildNavItem(
                  icon: Icons.medical_services,
                  label: 'Find Vets',
                  isSelected: _selectedNavItem == 'vets',
                  onTap: () => _updateSelectedItem('vets'),
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: switch (_selectedNavItem) {
        'home' => _buildHomeContent(),
        'profile' => PetPatientProfilePage(
            onEditProfile: () => _updateSelectedItem('edit_profile'),
          ),
        'edit_profile' => EditPetPatientProfilePage(
            onSave: () => _updateSelectedItem('profile'),
          ),
        'book_appointment' => const PetBookAppointmentPage(),
        'appointments' => const PetAppointmentsPage(),
        'vets' => const Center(child: Text('Find Vets Page - Coming Soon')),
        'messages' => const PetPatientChatPage(),
        'settings' => const PetPatientSettingsPage(),
        _ => _buildHomeContent(),
      },
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  child: const Icon(Icons.pets, size: 40, color: Colors.teal),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${_patientData?['name'] ?? 'Pet'}!',
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
                          // Show confirmation dialog
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Row(
                                  children: [
                                    Icon(Icons.logout, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    const Text('Confirm Logout'),
                                  ],
                                ),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                  style: TextStyle(fontSize: 16),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm == true && mounted) {
                            try {
                              await FirebaseAuth.instance.signOut();
                              if (mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const WebHomePage(),
                                  ),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error signing out: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
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