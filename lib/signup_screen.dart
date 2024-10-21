import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart'; // Import the Login screen

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController(); // Changed to username
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  String errorMessage = '';

  // Method to register a user and save username to Firestore
  Future<void> _register() async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Optionally, update the display name for the user (not saved in Firestore)
      await userCredential.user?.updateDisplayName(usernameController.text.trim());

      // Save the username and email in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
      });

      // Navigate to the login screen or main app screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            width: double.infinity,
            child: Stack(
              children: [
                // Top part image section
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: size.height * 0.4,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/check.png"),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                // Form Section
                Positioned(
                  top: size.height * 0.35,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            "Create New Account",
                            style: GoogleFonts.bebasNeue(fontSize: 32),
                          ),
                          const SizedBox(height: 30),
                          RoundedInputField(
                            hintText: "Email",
                            icon: Icons.email,
                            controller: emailController,
                          ),
                          RoundedInputField(
                            hintText: "Username", // Changed from Name to Username
                            icon: Icons.person,
                            controller: usernameController, // Using username controller
                          ),
                          RoundedPasswordField(controller: passwordController),
                          RoundedButton(
                            text: "REGISTER",
                            press: _register, // Register action connected to Firebase
                          ),
                          const SizedBox(height: 10),
                          if (errorMessage.isNotEmpty)
                            Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Already have an account? Login here",
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// RoundedButton widget
class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback press;
  final Color color, textColor;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = Colors.blue,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: press,
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }
}

// RoundedInputField widget
class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextEditingController controller;

  const RoundedInputField({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.blue),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

// RoundedPasswordField widget
class RoundedPasswordField extends StatefulWidget {
  final TextEditingController controller;

  const RoundedPasswordField({Key? key, required this.controller})
      : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _isHidden,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock, color: Colors.blue),
          hintText: "Password",
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              _isHidden ? Icons.visibility_off : Icons.visibility,
              color: Colors.blue,
            ),
            onPressed: () {
              setState(() {
                _isHidden = !_isHidden;
              });
            },
          ),
        ),
      ),
    );
  }
}
