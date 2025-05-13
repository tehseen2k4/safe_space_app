import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/models/humanappointment_db.dart';
import 'package:safe_space_app/models/petappointment_db.dart';
import 'package:safe_space_app/web/pages/doctor/doctor_profile_page.dart';
import 'myappointmentsdoctorpage.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _selectedNavItem = 'home';
  bool _isSidebarCollapsed = false;
  Map<String, dynamic>? _doctorData;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  void _loadMockData() {
    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _doctorData = {
          'name': 'John Smith',
          'email': 'john.smith@example.com',
          'phone': '+1 (555) 123-4567',
          'dob': '1985-05-15',
          'gender': 'Male',
          'clinicName': 'Safe Space Medical Center',
          'address': '123 Medical Plaza',
          'city': 'New York',
          'state': 'NY',
          'pincode': '10001',
          'specialization': 'General Medicine',
          'qualification': 'MBBS, MD',
          'experience': '10',
          'licenseNumber': 'MD123456',
          'registrationNumber': 'REG789012',
          'bio': 'Dr. John Smith is a highly experienced general physician with over 10 years of practice. He specializes in preventive care and chronic disease management. His approach focuses on building long-term relationships with patients and providing comprehensive healthcare solutions.',
        };
        _isLoading = false;
      });
    });
  }

  void _handleLogout() {
    // TODO: Implement logout functionality
    print('Logout clicked');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          // Sidebar Navigation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 80 : 280,
            color: Colors.white,
            child: Column(
              children: [
                // Logo and Brand
                Container(
                  padding: EdgeInsets.all(_isSidebarCollapsed ? 16 : 24),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.teal, Colors.teal.shade300],
                    ),
                  ),
                  child: Center(
                    child: _isSidebarCollapsed
                        ? const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 32,
                          )
                        : const Text(
                            'SAFE-SPACE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildNavItem(
                        Icons.dashboard,
                        'Dashboard',
                        'home',
                      ),
                      _buildNavItem(
                        Icons.calendar_today,
                        'Appointments',
                        'appointments',
                        badgeCount: 2,
                      ),
                      _buildNavItem(
                        Icons.people,
                        'Patients',
                        'patients',
                      ),
                      _buildNavItem(
                        Icons.medical_services,
                        'Services',
                        'services',
                      ),
                      _buildNavItem(
                        Icons.message,
                        'Messages',
                        'messages',
                        badgeCount: 3,
                      ),
                      _buildNavItem(
                        Icons.star,
                        'Reviews',
                        'reviews',
                      ),
                      const Divider(height: 32),
                      _buildNavItem(
                        Icons.person,
                        'Profile',
                        'profile',
                      ),
                      _buildNavItem(
                        Icons.settings,
                        'Settings',
                        'settings',
                      ),
                      _buildNavItem(
                        Icons.help,
                        'Help & Support',
                        'help',
                      ),
                      const Divider(height: 32),
                      _buildNavItem(
                        Icons.logout,
                        'Logout',
                        'logout',
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      IconButton(
                        icon: Icon(
                          _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
                          color: Colors.teal,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSidebarCollapsed = !_isSidebarCollapsed;
                          });
                        },
                      ),
                      const SizedBox(width: 16),
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
                      CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Icon(Icons.person, color: Colors.teal),
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

  String _getPageTitle() {
    switch (_selectedNavItem) {
      case 'home':
        return 'Dashboard';
      case 'appointments':
        return 'Appointments';
      case 'patients':
        return 'Patients';
      case 'services':
        return 'Services';
      case 'messages':
        return 'Messages';
      case 'reviews':
        return 'Reviews';
      case 'profile':
        return 'Profile';
      case 'settings':
        return 'Settings';
      case 'help':
        return 'Help & Support';
      default:
        return 'Dashboard';
    }
  }

  Widget _buildNavItem(IconData icon, String title, String navItem, {int? badgeCount, VoidCallback? onTap}) {
    final isSelected = _selectedNavItem == navItem;
    Widget listTile = ListTile(
      leading: Stack(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.teal : Colors.grey[600],
          ),
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: _isSidebarCollapsed ? null : Text(title),
      selected: isSelected,
      selectedTileColor: Colors.teal.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onTap: onTap ?? () {
        setState(() {
          _selectedNavItem = navItem;
        });
      },
    );

    return _isSidebarCollapsed
        ? Tooltip(
            message: title,
            child: listTile,
          )
        : listTile;
  }

  Widget _buildMainContent() {
    switch (_selectedNavItem) {
      case 'home':
        return _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 32),
                    _buildStatsSection(),
                    const SizedBox(height: 32),
                    _buildAppointmentsSection(),
                    const SizedBox(height: 32),
                    _buildReviewsSection(),
                  ],
                ),
              );
      case 'appointments':
        return const MyAppointmentsDoctorPage();
      case 'profile':
        return DoctorProfilePage(doctorData: _doctorData);
      case 'settings':
        return const Center(child: Text('Settings Page'));
      case 'help':
        return const Center(child: Text('Help & Support Page'));
      default:
        return const Center(child: Text('Page Not Found'));
    }
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.teal,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Dr. ${_doctorData?['name'] ?? 'Doctor'}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _doctorData?['specialization'] ?? 'Specialization',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _doctorData?['qualification'] ?? 'Qualification',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 24,
      children: [
        _buildStatCard(
          'Total Appointments',
          '24',
          Icons.calendar_today,
          Colors.blue,
        ),
        _buildStatCard(
          'Today\'s Patients',
          '8',
          Icons.people,
          Colors.green,
        ),
        _buildStatCard(
          'Pending Reports',
          '3',
          Icons.description,
          Colors.orange,
        ),
        _buildStatCard(
          'Messages',
          '12',
          Icons.message,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedNavItem = 'appointments';
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            return _buildAppointmentCard({
              'username': 'Patient ${index + 1}',
              'timeslot': '${9 + index}:00 AM - ${10 + index}:00 AM',
              'reasonforvisit': 'Regular checkup',
            });
          },
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    child: const Icon(Icons.person, color: Colors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      appointment['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.watch_later, color: Colors.teal, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    appointment['timeslot'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedNavItem = 'appointments';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 40),
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Reviews',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5,
          ),
          itemCount: 3,
          itemBuilder: (context, index) {
            final reviews = [
              {
                "review": "Excellent doctor! Very professional and caring.",
                "rating": 5,
                "date": "2 days ago"
              },
              {
                "review": "Great consultation and follow-up care.",
                "rating": 4,
                "date": "3 days ago"
              },
              {
                "review": "Very knowledgeable and patient-friendly.",
                "rating": 5,
                "date": "5 days ago"
              },
            ];
            return _buildReviewCard(
              reviews[index]["review"] as String,
              reviews[index]["rating"] as int,
              reviews[index]["date"] as String,
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(String review, int rating, String date) {
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Anonymous Patient',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      rating,
                      (index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}