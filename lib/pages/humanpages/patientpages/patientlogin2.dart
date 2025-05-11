import 'package:flutter/material.dart';
import 'package:safe_space_app/pages/humanpages/patientpages/humanpatientprofile.dart';
import 'package:safe_space_app/pages/petpages/petpatientprofile.dart';

class PatientLogin extends StatelessWidget {
  const PatientLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return WillPopScope(
      onWillPop: () async {
        bool? shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.only(top: 24),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            actionsPadding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
            title: Column(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                  radius: 28,
                  child: const Icon(Icons.logout, color: Color(0xFF1976D2), size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: const Text(
              'Are you sure you want to log out?',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
        return shouldLogout ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : (isTablet ? 600 : screenSize.width),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 20 : 0),
                vertical: isDesktop ? 40 : 20,
              ),
              child: Column(
                children: [
                  SizedBox(height: isDesktop ? 40 : 20),
                  // Header Section
                  Icon(
                    Icons.health_and_safety_rounded,
                    size: isDesktop ? 80 : (isTablet ? 70 : 60),
                    color: const Color(0xFF1976D2),
                  ),
                  SizedBox(height: isDesktop ? 30 : 20),
                  Text(
                    'SAFE-SPACE',
                    style: TextStyle(
                      fontSize: isDesktop ? 45 : (isTablet ? 40 : 35),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 15 : 10),
                  Text(
                    'Choose Your Care Type',
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : (isTablet ? 20 : 18),
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 60 : 50),

                  // Human Patient Section
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : (isTablet ? 30 : 30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HumanPatientProfile(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 25 : 20,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isDesktop ? 32 : 28,
                          ),
                          SizedBox(width: isDesktop ? 15 : 10),
                          Column(
                            children: [
                              Text(
                                'Human',
                                style: TextStyle(
                                  fontSize: isDesktop ? 28 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Access human healthcare services',
                                style: TextStyle(
                                  fontSize: isDesktop ? 14 : 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 30 : 25),

                  // Pet Patient Section
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : (isTablet ? 30 : 30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Petpatientprofile(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA726),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 25 : 20,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            size: isDesktop ? 32 : 28,
                          ),
                          SizedBox(width: isDesktop ? 15 : 10),
                          Column(
                            children: [
                              Text(
                                'Pet',
                                style: TextStyle(
                                  fontSize: isDesktop ? 28 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Access pet healthcare services',
                                style: TextStyle(
                                  fontSize: isDesktop ? 14 : 12,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 60 : 50),

                  // Footer Description
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : (isTablet ? 30 : 30),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Comprehensive Healthcare Solutions',
                          style: TextStyle(
                            fontSize: isDesktop ? 20 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        SizedBox(height: isDesktop ? 15 : 10),
                        Text(
                          'Expert medical care for both you and your beloved pets, available 24/7 at your convenience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            color: const Color(0xFF666666),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
