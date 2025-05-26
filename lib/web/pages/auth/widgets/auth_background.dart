import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.withOpacity(0.15),
                Colors.teal.withOpacity(0.05),
                Colors.teal.withOpacity(0.1),
              ],
            ),
          ),
        ),
        // Doodle patterns
        Positioned(
          top: 50,
          right: 50,
          child: _buildDoodle(
            Icons.favorite,
            Colors.teal.withOpacity(0.12),
            size: 100,
          ),
        ),
        Positioned(
          bottom: 100,
          left: 50,
          child: _buildDoodle(
            Icons.medical_services,
            Colors.teal.withOpacity(0.12),
            size: 80,
          ),
        ),
        Positioned(
          top: 200,
          left: 100,
          child: _buildDoodle(
            Icons.health_and_safety,
            Colors.teal.withOpacity(0.12),
            size: 60,
          ),
        ),
        Positioned(
          bottom: 200,
          right: 100,
          child: _buildDoodle(
            Icons.person,
            Colors.teal.withOpacity(0.12),
            size: 70,
          ),
        ),
        // Additional doodles
        Positioned(
          top: 150,
          right: 150,
          child: _buildDoodle(
            Icons.local_hospital,
            Colors.teal.withOpacity(0.12),
            size: 45,
          ),
        ),
        Positioned(
          bottom: 150,
          left: 150,
          child: _buildDoodle(
            Icons.medication,
            Colors.teal.withOpacity(0.12),
            size: 55,
          ),
        ),
        Positioned(
          top: 300,
          left: 200,
          child: _buildDoodle(
            Icons.medical_information,
            Colors.teal.withOpacity(0.12),
            size: 40,
          ),
        ),
        Positioned(
          bottom: 300,
          right: 200,
          child: _buildDoodle(
            Icons.healing,
            Colors.teal.withOpacity(0.12),
            size: 50,
          ),
        ),
        Positioned(
          top: 400,
          right: 300,
          child: _buildDoodle(
            Icons.health_and_safety,
            Colors.teal.withOpacity(0.12),
            size: 35,
          ),
        ),
        Positioned(
          bottom: 400,
          left: 300,
          child: _buildDoodle(
            Icons.medical_services,
            Colors.teal.withOpacity(0.12),
            size: 45,
          ),
        ),
      ],
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