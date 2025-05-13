import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../pages/auth/auth_selection_page.dart';

class WebLayout extends StatefulWidget {
  final Widget child;
  
  const WebLayout({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<WebLayout> createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
  int _selectedIndex = 0;
  bool _isAuthenticated = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleAuthentication() {
    setState(() {
      _isAuthenticated = !_isAuthenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Bar with Logo and Actions
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      // Logo and Title
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.teal,
                                  Colors.teal.withOpacity(0.8),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.teal.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.health_and_safety,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safe Space',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Healthcare',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.teal.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: const Icon(Icons.search, color: Colors.teal, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Quick Actions
                      if (_isAuthenticated) ...[
                        _buildActionButton(
                          icon: Icons.notifications,
                          badge: '3',
                          onTap: () {},
                        ),
                        _buildActionButton(
                          icon: Icons.help_outline,
                          onTap: () {},
                        ),
                        const SizedBox(width: 16),
                        _buildProfileButton(),
                      ] else ...[
                        _buildAuthButton('Sign In', true),
                        const SizedBox(width: 12),
                        _buildAuthButton('Sign Up', false),
                      ],
                    ],
                  ),
                ),
                // Navigation Menu
                if (_isAuthenticated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildNavItem(
                          icon: Icons.dashboard,
                          title: 'Dashboard',
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.calendar_today,
                          title: 'Appointments',
                          index: 1,
                        ),
                        _buildNavItem(
                          icon: Icons.medical_services,
                          title: 'Services',
                          index: 2,
                        ),
                        _buildNavItem(
                          icon: Icons.people,
                          title: 'Doctors',
                          index: 3,
                        ),
                        _buildNavItem(
                          icon: Icons.chat,
                          title: 'Chat',
                          index: 4,
                        ),
                        _buildNavItem(
                          icon: Icons.group,
                          title: 'Community',
                          index: 5,
                        ),
                        const Spacer(),
                        _buildNavItem(
                          icon: Icons.person,
                          title: 'Profile',
                          index: 6,
                        ),
                        _buildNavItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          index: 7,
                        ),
                        _buildNavItem(
                          icon: Icons.help,
                          title: 'Help',
                          index: 8,
                        ),
                        _buildNavItem(
                          icon: Icons.logout,
                          title: 'Sign Out',
                          index: -2,
                          onTap: _handleAuthentication,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton(String text, bool isPrimary) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthSelectionPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.teal,
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.teal, size: 20),
            onPressed: onTap,
          ),
        ),
        if (badge != null)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.person, color: Colors.teal, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.teal : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.teal : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}