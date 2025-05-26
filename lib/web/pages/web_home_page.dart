import 'package:flutter/material.dart';
import 'auth/auth_selection_page.dart';
import 'dart:math';
import 'auth/widgets/auth_background.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolled = false;
  final List<Map<String, dynamic>> _stats = [
    {'value': '50+', 'label': 'Expert Doctors', 'icon': Icons.people},
    {'value': '10k+', 'label': 'Happy Patients', 'icon': Icons.favorite},
    {'value': '24/7', 'label': 'Medical Support', 'icon': Icons.support_agent},
    {'value': '15+', 'label': 'Years Experience', 'icon': Icons.work},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section with Enhanced Teal Background
            Container(
              height: 700,
              child: Stack(
                children: [
                  // Custom background with enhanced teal gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.teal.withOpacity(0.25),
                          Colors.teal.withOpacity(0.15),
                          Colors.teal.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                  // Medical icons with enhanced opacity
                  Positioned(
                    top: 50,
                    right: 50,
                    child: _buildDoodle(
                      Icons.favorite,
                      Colors.teal.withOpacity(0.15),
                      size: 100,
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: 50,
                    child: _buildDoodle(
                      Icons.medical_services,
                      Colors.teal.withOpacity(0.15),
                      size: 80,
                    ),
                  ),
                  Positioned(
                    top: 200,
                    left: 100,
                    child: _buildDoodle(
                      Icons.health_and_safety,
                      Colors.teal.withOpacity(0.15),
                      size: 60,
                    ),
                  ),
                  Positioned(
                    bottom: 200,
                    right: 100,
                    child: _buildDoodle(
                      Icons.person,
                      Colors.teal.withOpacity(0.15),
                      size: 70,
                    ),
                  ),
                  Positioned(
                    top: 150,
                    right: 150,
                    child: _buildDoodle(
                      Icons.local_hospital,
                      Colors.teal.withOpacity(0.15),
                      size: 45,
                    ),
                  ),
                  Positioned(
                    bottom: 150,
                    left: 150,
                    child: _buildDoodle(
                      Icons.medication,
                      Colors.teal.withOpacity(0.15),
                      size: 55,
                    ),
                  ),
                  Positioned(
                    top: 300,
                    left: 200,
                    child: _buildDoodle(
                      Icons.medical_information,
                      Colors.teal.withOpacity(0.15),
                      size: 40,
                    ),
                  ),
                  Positioned(
                    bottom: 300,
                    right: 200,
                    child: _buildDoodle(
                      Icons.healing,
                      Colors.teal.withOpacity(0.15),
                      size: 50,
                    ),
                  ),
                  // Content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Animation
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(seconds: 1),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
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
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.health_and_safety,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          // Title with Fade Animation
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: _isScrolled ? 0.0 : 1.0,
                            child: const Text(
                              'Welcome to Safe Space',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Subtitle with Slide Animation
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: _isScrolled ? 0.0 : 1.0,
                            child: const Text(
                              'Your trusted healthcare companion for mental and physical well-being',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnimatedButton(
                                'Get Started',
                                Colors.teal,
                                true,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuthSelectionPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 24),
                              _buildAnimatedButton(
                                'Learn More',
                                Colors.teal,
                                false,
                                () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _stats.map((stat) => _buildStatCard(stat)).toList(),
              ),
            ),

            // Services Section with Cards
            _buildSection(
              'Our Services',
              'Comprehensive healthcare solutions for your well-being',
              [
                _buildServiceCard(
                  icon: Icons.medical_services,
                  title: 'Medical Services',
                  description: 'Access to qualified healthcare professionals',
                  features: [
                    'Online Consultations',
                    'Prescription Management',
                    'Health Records',
                    'Emergency Support',
                  ],
                ),
                _buildServiceCard(
                  icon: Icons.psychology,
                  title: 'Mental Health',
                  description: 'Professional counseling and therapy services',
                  features: [
                    'Virtual Therapy Sessions',
                    'Support Groups',
                    'Wellness Programs',
                    'Stress Management',
                  ],
                ),
                _buildServiceCard(
                  icon: Icons.people,
                  title: 'Community Support',
                  description: 'Connect with others in a safe environment',
                  features: [
                    'Peer Support',
                    'Discussion Forums',
                    'Resource Sharing',
                    'Success Stories',
                  ],
                ),
              ],
            ),

            // Featured Doctors Section
            _buildSection(
              'Our Expert Doctors',
              'Meet our team of experienced healthcare professionals',
              [
                _buildDoctorCard(
                  name: 'Dr. Sarah Johnson',
                  specialty: 'Psychiatrist',
                  imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                  rating: 4.9,
                  experience: '15 years',
                  availability: 'Mon-Fri, 9AM-5PM',
                ),
                _buildDoctorCard(
                  name: 'Dr. Michael Chen',
                  specialty: 'General Physician',
                  imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                  rating: 4.8,
                  experience: '12 years',
                  availability: 'Mon-Sat, 8AM-6PM',
                ),
                _buildDoctorCard(
                  name: 'Dr. Emily Brown',
                  specialty: 'Therapist',
                  imageUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                  rating: 4.7,
                  experience: '10 years',
                  availability: 'Mon-Fri, 10AM-7PM',
                ),
              ],
            ),

            // Testimonials Section with Carousel
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80),
              color: Colors.grey[50],
              child: Column(
                children: [
                  const Text(
                    'What Our Users Say',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Real experiences from our valued patients',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildTestimonialCard(
                          name: 'John Doe',
                          role: 'Patient',
                          testimonial: 'Safe Space has been a game-changer for my mental health journey. The support and care I\'ve received are exceptional.',
                          rating: 5,
                          imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                        ),
                        _buildTestimonialCard(
                          name: 'Jane Smith',
                          role: 'Patient',
                          testimonial: 'The community support here is incredible. I\'ve never felt more understood and supported in my healthcare journey.',
                          rating: 5,
                          imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                        ),
                        _buildTestimonialCard(
                          name: 'Mike Johnson',
                          role: 'Patient',
                          testimonial: 'Professional and caring doctors. The online consultation feature is a lifesaver for busy professionals like me.',
                          rating: 5,
                          imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contact Section with Map
            Container(
              padding: const EdgeInsets.all(80.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.teal,
                    Colors.teal.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We\'re here to help and answer any questions you might have',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactInfo(
                        icon: Icons.email,
                        title: 'Email',
                        content: 'support@safespace.com',
                        onTap: () {},
                      ),
                      _buildContactInfo(
                        icon: Icons.phone,
                        title: 'Phone',
                        content: '+1 (555) 123-4567',
                        onTap: () {},
                      ),
                      _buildContactInfo(
                        icon: Icons.location_on,
                        title: 'Address',
                        content: '123 Healthcare Street, Medical City, MC 12345',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Newsletter Subscription
                  Container(
                    width: 600,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Subscribe to Our Newsletter',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Stay updated with the latest healthcare news and tips',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter your email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildAnimatedButton(
                              'Subscribe',
                              Colors.teal,
                              true,
                              () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            stat['icon'] as IconData,
            size: 48,
            color: Colors.teal,
          ),
          const SizedBox(height: 16),
          Text(
            stat['value'] as String,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stat['label'] as String,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(80.0),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedButton(
    String text,
    Color color,
    bool isFilled,
    VoidCallback onPressed,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: isFilled ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color,
              width: 2,
            ),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isFilled ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
  }) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.teal,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDoctorCard({
    required String name,
    required String specialty,
    required String imageUrl,
    required double rating,
    required String experience,
    required String availability,
  }) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip(
                      Icons.star,
                      rating.toString(),
                      Colors.amber,
                    ),
                    const SizedBox(width: 16),
                    _buildInfoChip(
                      Icons.work,
                      experience,
                      Colors.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.teal,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        availability,
                        style: const TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildAnimatedButton(
                  'Book Appointment',
                  Colors.teal,
                  true,
                  () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String name,
    required String role,
    required String testimonial,
    required int rating,
    required String imageUrl,
  }) {
    return Container(
      width: 400,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  rating,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            testimonial,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoodle(IconData icon, Color color, {required double size}) {
    return Transform.rotate(
      angle: 0.2,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
} 