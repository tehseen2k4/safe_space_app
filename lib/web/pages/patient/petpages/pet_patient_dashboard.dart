import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/humandoctordetail.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/appointmentbooking.dart';
import 'package:safe_space_app/mobile/pages/humanpages/patientpages/appointmentlistpage.dart';
import 'package:safe_space_app/mobile/pages/chatpages/Home_page.dart';
import 'package:safe_space_app/web/pages/patient/petpages/pet_patient_profile_page.dart';

class PetPatientDashboard extends StatefulWidget {
  const PetPatientDashboard({Key? key}) : super(key: key);

  @override
  State<PetPatientDashboard> createState() => _PetPatientDashboardState();
}

class _PetPatientDashboardState extends State<PetPatientDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String _selectedNavItem = 'home';
  bool _isSidebarCollapsed = false;
  Map<String, dynamic>? _patientData;
  List<Map<String, dynamic>> _veterinarianList = [];
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _loadPatientData();
    _loadVeterinarians();
    _loadAppointments();
  }

  Future<void> _loadPatientData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final querySnapshot = await _firestore
            .collection('petpatients')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _patientData = querySnapshot.docs.first.data();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading patient data: $e");
      setState(() {
        _patientData = {
          'name': 'Max',
          'species': 'Dog',
          'breed': 'Golden Retriever',
          'age': 3,
          'ownerName': 'John Doe',
          'ownerEmail': 'john.doe@example.com',
          'ownerPhone': '+1 234 567 8900',
          'weight': '25 kg',
          'lastCheckup': '2024-02-15',
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVeterinarians() async {
    try {
      final querySnapshot = await _firestore.collection('veterinarians').get();
      setState(() {
        _veterinarianList = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading veterinarians: $e");
      setState(() {
        _veterinarianList = [
          {
            'name': 'Dr. Sarah Johnson',
            'specialization': 'Small Animal Medicine',
            'experience': '15',
            'rating': '4.8',
            'clinic': 'Paws & Care Veterinary Clinic',
            'availability': 'Mon-Fri, 9AM-5PM',
          },
          {
            'name': 'Dr. Michael Chen',
            'specialization': 'Pet Surgery',
            'experience': '12',
            'rating': '4.9',
            'clinic': 'Animal Health Center',
            'availability': 'Mon-Sat, 10AM-6PM',
          },
          {
            'name': 'Dr. Emily Brown',
            'specialization': 'Pet Dentistry',
            'experience': '10',
            'rating': '4.7',
            'clinic': 'Pet Dental Care',
            'availability': 'Mon-Fri, 8AM-4PM',
          },
          {
            'name': 'Dr. James Wilson',
            'specialization': 'Emergency Care',
            'experience': '20',
            'rating': '4.9',
            'clinic': '24/7 Pet Emergency',
            'availability': '24/7',
          },
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() {
        _appointments = [
          {
            'doctorName': 'Dr. Sarah Johnson',
            'specialization': 'Veterinary Checkup',
            'date': '2024-03-20',
            'time': '10:00 AM',
            'status': 'Upcoming',
            'clinic': 'Paws & Care Veterinary Clinic',
            'reason': 'Annual Checkup'
          },
          {
            'doctorName': 'Dr. Michael Chen',
            'specialization': 'Vaccination',
            'date': '2024-03-22',
            'time': '2:30 PM',
            'status': 'Confirmed',
            'clinic': 'Animal Health Center',
            'reason': 'Rabies Vaccination'
          },
          {
            'doctorName': 'Dr. Emily Brown',
            'specialization': 'Dental Cleaning',
            'date': '2024-03-25',
            'time': '11:15 AM',
            'status': 'Pending',
            'clinic': 'Pet Dental Care',
            'reason': 'Regular Dental Checkup'
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading appointments: $e");
      _isLoading = false;
    }
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
                            Icons.pets,
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
                        badgeCount: _appointments.length,
                      ),
                      _buildNavItem(
                        Icons.medical_services,
                        'Find Veterinarians',
                        'veterinarians',
                      ),
                      _buildNavItem(
                        Icons.local_hospital,
                        'Pet Hospitals',
                        'hospitals',
                      ),
                      _buildNavItem(
                        Icons.message,
                        'Messages',
                        'messages',
                        badgeCount: 3,
                      ),
                      const Divider(height: 32),
                      _buildNavItem(
                        Icons.pets,
                        'Pet Profile',
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
                        onTap: () {
                          // TODO: Implement logout
                        },
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
                        child: const Icon(Icons.pets, color: Colors.teal),
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
        return 'My Appointments';
      case 'veterinarians':
        return 'Find Veterinarians';
      case 'hospitals':
        return 'Pet Hospitals';
      case 'messages':
        return 'Messages';
      case 'profile':
        return 'Pet Profile';
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
                    _buildQuickActions(),
                    const SizedBox(height: 32),
                    _buildUpcomingAppointments(),
                    const SizedBox(height: 32),
                    _buildRecommendedVeterinarians(),
                  ],
                ),
              );
      case 'appointments':
        return AppointmentsPage();
      case 'veterinarians':
        return HumanDoctorDetail();
      case 'messages':
        return HomePage();
      case 'profile':
        return PetPatientProfilePage(patientData: _patientData);
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
              Icons.pets,
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
                  'Welcome back, ${_patientData?['name'] ?? 'Pet'}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Pet\'s Health is Our Priority',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 24,
      children: [
        _buildActionCard(
          'Book Appointment',
          Icons.calendar_today,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookAppointmentPage()),
            );
          },
        ),
        _buildActionCard(
          'Find Veterinarians',
          Icons.medical_services,
          Colors.green,
          () {
            setState(() {
              _selectedNavItem = 'veterinarians';
            });
          },
        ),
        _buildActionCard(
          'Messages',
          Icons.message,
          Colors.purple,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        _buildActionCard(
          'Pet Profile',
          Icons.pets,
          Colors.orange,
          () {
            setState(() {
              _selectedNavItem = 'profile';
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
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
          itemCount: _appointments.length,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(_appointments[index]);
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
                      appointment['doctorName'],
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
                    '${appointment['date']} at ${appointment['time']}',
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

  Widget _buildRecommendedVeterinarians() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Veterinarians',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _veterinarianList.length,
            itemBuilder: (context, index) {
              final veterinarian = _veterinarianList[index];
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 24),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                veterinarian['name'] ?? 'Unknown Veterinarian',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                veterinarian['specialization'] ?? 'General Medicine',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${veterinarian['experience'] ?? '0'} Years Experience',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookAppointmentPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('Book Appointment'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 