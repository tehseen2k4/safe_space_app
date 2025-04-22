import 'package:flutter/material.dart';
import 'package:safe_space/pages/editprofilehuman.dart';
import 'package:safe_space/models/patients_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
      home: ViewProfileHumanScreen(),
    );
  }
}

class ViewProfileHumanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              ProfilePhoto(),
              SizedBox(height: 30),
              ProfileInfoSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePhoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            image: DecorationImage(
              image: AssetImage('assets/images/one.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 10),
        TextButton.icon(
          onPressed: () {},
          icon: Icon(Icons.camera_alt,
              color: const Color.fromARGB(255, 2, 93, 98)),
          label: Text(
            'Change Photo',
            style: TextStyle(
                color: const Color.fromARGB(255, 2, 93, 98),
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ProfileInfoSection extends StatelessWidget {
  Future<PatientsDb> fetchProfile(String uid) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('humanpatients')
          .where('uid', isEqualTo: uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return PatientsDb.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        throw Exception('Profile not found.');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<PatientsDb>(
      future: fetchProfile(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return ErrorButton();
        } else if (!snapshot.hasData) {
          return Center(child: Text('Profile not found.'));
        } else {
          final patient = snapshot.data!;

          return Column(
            children: [
              ProfileInfoCard(title: 'Name', value: patient.name),
              ProfileInfoCard(title: 'Username', value: patient.username),
              ProfileInfoCard(title: 'Age', value: patient.age.toString()),
              ProfileInfoCard(title: 'Sex', value: patient.sex),
              ProfileInfoCard(title: 'Blood Group', value: patient.bloodgroup),
              ProfileInfoCard(title: 'Email', value: patient.email),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditPageHuman()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: const Color.fromARGB(255, 2, 93, 98),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isGreyed;

  ProfileInfoCard(
      {required this.title, required this.value, this.isGreyed = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w800),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isGreyed ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EditPageHuman()),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        backgroundColor: const Color.fromARGB(255, 2, 93, 98),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Create Profile',
        style: TextStyle(
            fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
