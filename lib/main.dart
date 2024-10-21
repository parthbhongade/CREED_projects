import 'package:billstore_2/splashacreen.dart'; // Your custom splash screen
import 'package:firebase_core/firebase_core.dart';  // Import Firebase core
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Ensure binding is initialized
  await Firebase.initializeApp();
  setAuthPersistence();
  // Initialize Firebase
  runApp(const MyApp());
}

void setAuthPersistence() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  await _auth.setPersistence(Persistence.LOCAL).then((_) {
    // Now the user will stay logged in until they log out.
    print("Persistence set to local");
  }).catchError((error) {
    print("Error setting persistence: $error");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillStore',   // App title
      debugShowCheckedModeBanner: false,  // Hide debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,  // Primary color theme
        fontFamily: 'Roboto',         // Set global font (optional)
      ),
      home: SplashScreen(),    // Set splash screen as the home
    );
  }
}
