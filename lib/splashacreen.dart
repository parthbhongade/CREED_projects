import 'dart:async';
import 'package:billstore_2/Screen1.dart'; // Your main screen after login
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // For animations (optional)
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login_screen.dart'; // Import the Login screen

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkAuthentication(); // Check authentication status on init
  }

  Future<void> _checkAuthentication() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    // Delay for a short duration (optional)
    await Future.delayed(Duration(seconds: 2));

    User? user = _auth.currentUser; // Get the currently logged-in user

    if (user != null) {
      // If user is logged in, navigate to the main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Screen1()), // Replace with your main screen
      );
    } else {
      // If no user is logged in, navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to Login Page
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer if the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 166, 241, 236), // Background color
      body: Center(
        child: LottieBuilder.asset(
          "assets/lottie/Animation - 1728572018656.json",
          width: 500, // Adjusted width
          height: 500, // Adjusted height
        ),
      ),
    );
  }
}
