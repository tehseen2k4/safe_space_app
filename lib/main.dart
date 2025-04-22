import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:safe_space/pages/firstpage.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Required to ensure everything is initialized properly
  await Firebase.initializeApp(); // Wait until Firebase is initialized

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Safe Space App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: Firstpage(),
      //const LoginPage(),
    );
  }
}
