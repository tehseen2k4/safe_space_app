import 'package:flutter/material.dart';
//import 'Loginpage.dart';
import 'package:safe_space/pages/doctorlogin.dart';
//import 'package:safe_space/pages/doctorprofile.dart'; // Import HumanLogin page
import 'package:safe_space/pages/patientlogin.dart';

class Firstpage extends StatelessWidget {
  const Firstpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "SAFE-SPACE" Heading
          Text(
            'SAFE-SPACE',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 50), // Spacer between heading and buttons

          // Human and Pet Buttons
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to the HumanLogin page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Doctorpagee(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fixedSize: Size(200, 100), // Button size
                ),
                child: Text(
                  'Doctor',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 35), // Spacer between buttons
              ElevatedButton(
                onPressed: () {
                  // Navigate to the PetLogin page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LoginPage(), // Replace with your PetLogin page
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fixedSize: Size(200, 100), // Button size
                ),
                child: Text(
                  'Patient',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 60), // Spacer before footer text

          // Footer Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your one-stop solution for expert healthcare—caring for you and your pets, anytime, anywhere.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
