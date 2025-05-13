import 'package:flutter/material.dart';
//import 'Loginpage.dart';
import 'package:safe_space_app/pages/humanpages/doctorpages/doctorlogin.dart' as doctor;
//import 'package:safe_space/pages/doctorprofile.dart'; // Import HumanLogin page
import 'package:safe_space_app/pages/humanpages/patientpages/patientlogin.dart' as patient;

class Firstpage extends StatefulWidget {
  @override
  _FirstpageState createState() => _FirstpageState();
}

class _FirstpageState extends State<Firstpage> {
  void _navigateToDoctorLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => doctor.LoginPage(),
      ),
    );
  }

  void _navigateToPatientLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => patient.LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1200 : (isTablet ? 800 : screenSize.width),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : (isTablet ? 40 : 20),
                vertical: isDesktop ? 40 : 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Main Heading
                  const Icon(
                    Icons.health_and_safety_rounded,
                    size: 80,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SAFE-SPACE',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Trusted Healthcare Partner',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Buttons Container
                  if (isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _buildDoctorButton(context)),
                        const SizedBox(width: 30),
                        Expanded(child: _buildPatientButton(context)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildDoctorButton(context),
                        const SizedBox(height: 25),
                        _buildPatientButton(context),
                      ],
                    ),

                  const SizedBox(height: 50),

                  // Footer Description
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 100 : 30,
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Expert Healthcare at Your Fingertips',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Connect with trusted healthcare professionals, schedule appointments, and receive quality care from the comfort of your home.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
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

  Widget _buildDoctorButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        onPressed: _navigateToDoctorLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services, size: 28),
            const SizedBox(width: 10),
            Column(
              children: const [
                Text(
                  'Doctor',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Access your medical dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        onPressed: _navigateToPatientLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 28),
            const SizedBox(width: 10),
            Column(
              children: const [
                Text(
                  'Patient',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Book appointments & consultations',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
