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

class _WebLayoutState extends State<WebLayout> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  bool _isSidebarVisible = true;
  bool _isAuthenticated = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
      if (_isSidebarVisible) {
        _isSidebarExpanded = true;
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleAuthentication() {
    setState(() {
      _isAuthenticated = !_isAuthenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Modern Sidebar
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: _isSidebarVisible
                    ? (_isSidebarExpanded ? 280 : 80) * _animation.value
                    : 0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: Column(
              children: [
                // Logo and Title Section
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        color: Color(0xFF2196F3),
                        size: 32,
                      ),
                      if (_isSidebarExpanded) ...[
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safe Space',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Healthcare',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      if (!_isAuthenticated) ...[
                        _buildNavItem(
                          icon: Icons.login,
                          title: 'Sign In',
                          index: -1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthSelectionPage(),
                              ),
                            );
                          },
                        ),
                      ] else ...[
                        _buildNavItem(
                          icon: Icons.home,
                          title: 'Home',
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.medical_services,
                          title: 'Services',
                          index: 1,
                        ),
                        _buildNavItem(
                          icon: Icons.people,
                          title: 'Doctors',
                          index: 2,
                        ),
                        _buildNavItem(
                          icon: Icons.chat,
                          title: 'Chat',
                          index: 3,
                        ),
                        _buildNavItem(
                          icon: Icons.group,
                          title: 'Community',
                          index: 4,
                        ),
                        _buildNavItem(
                          icon: Icons.person,
                          title: 'Profile',
                          index: 5,
                        ),
                        const Divider(height: 32),
                        _buildNavItem(
                          icon: Icons.settings,
                          title: 'Settings',
                          index: 6,
                        ),
                        _buildNavItem(
                          icon: Icons.help,
                          title: 'Help',
                          index: 7,
                        ),
                        _buildNavItem(
                          icon: Icons.logout,
                          title: 'Sign Out',
                          index: -2,
                          onTap: _handleAuthentication,
                        ),
                      ],
                    ],
                  ),
                ),
                // Toggle Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: Icon(
                      _isSidebarExpanded ? Icons.chevron_left : Icons.chevron_right,
                      color: const Color(0xFF2196F3),
                    ),
                    onPressed: () {
                      setState(() {
                        _isSidebarExpanded = !_isSidebarExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Colors.grey[50],
                  child: widget.child,
                ),
                // Sidebar Toggle Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isSidebarVisible ? Icons.menu_open : Icons.menu,
                        color: const Color(0xFF2196F3),
                      ),
                      onPressed: _toggleSidebar,
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

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required int index,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
      ),
      title: _isSidebarExpanded
          ? Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          : null,
      selected: isSelected,
      onTap: onTap ?? () {
        setState(() {
          _selectedIndex = index;
        });
      },
      hoverColor: const Color(0xFF2196F3).withOpacity(0.1),
    );
  }
} 