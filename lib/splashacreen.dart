import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart'; // For animations (optional)
import 'package:lottie/lottie.dart';
import 'loginpage.dart'; // Import the HomePage (login page) here

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Initiate a timer to navigate to the HomePage (Login Page) after 5 seconds
    _timer = Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), // Navigate to HomePage (Login Page)
      );
    });
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
