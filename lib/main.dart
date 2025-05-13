import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:safe_space_app/mobile/pages/firstpage.dart';
import 'package:safe_space_app/web/layouts/web_layout.dart';
import 'package:safe_space_app/web/pages/web_home_page.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD4_qs2Q_Q0KJxcZMuHwjF-xcaozcAXDKI",
        authDomain: "safe-space-app-ceef4.firebaseapp.com",
        projectId: "safe-space-app-ceef4",
        storageBucket: "safe-space-app-ceef4.appspot.com",
        messagingSenderId: "857512628788",
        appId: "1:857512628788:web:b09ce361ffcfec644ff061",
      ),
    );
  } else {
    await Firebase.initializeApp();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(const MyApp());
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
        useMaterial3: true,
      ),
      home: kIsWeb 
        ? const WebLayout(child: WebHomePage())
        : const Firstpage(),
    );
  }
}