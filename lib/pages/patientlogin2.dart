import 'package:flutter/material.dart';
import 'package:safe_space/pages/humanpatientprofile.dart';
import 'package:safe_space/pages/petpatientprofile.dart';

class PatientLogin extends StatelessWidget {
  const PatientLogin({super.key});

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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HumanPatientProfile(),
                      ));
                  // Add navigation logic for Human section here
                  print("Human button clicked!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 2, 93, 98), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fixedSize: Size(200, 100), // Button size
                ),
                child: Text(
                  'Human',
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Petpatientprofile(),
                      ));
                  // Add navigation logic for Pet section here
                  print("Pet button clicked!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 250, 160, 43), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  fixedSize: Size(200, 100), // Button size
                ),
                child: Text(
                  'Pet',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 100), // Spacer before footer text

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
