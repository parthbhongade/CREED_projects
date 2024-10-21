import 'package:cloud_firestore/cloud_firestore.dart'; // Import cloud_firestore
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import firebase_auth
import 'package:fluttertoast/fluttertoast.dart';   // For showing toast messages
import 'Screen1.dart';
import 'signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance; // Firebase Auth instance
  final _emailController = TextEditingController(); // Controllers for email input
  final _passwordController = TextEditingController(); // Controllers for password input
  bool rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle login
  Future<void> _login() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (userCredential.user != null) {
        Fluttertoast.showToast(msg: 'Login successful!');
        // Navigate to the next screen after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Screen1()), // Replace Screen1 with your home page
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "An error occurred";
      Fluttertoast.showToast(msg: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Stack(
              children: [
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image(
                    image: AssetImage("assets/images/log-in.png"),
                    height: 200,
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Login to your account',
                      style: GoogleFonts.bebasNeue(fontSize: 32),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 280.0),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 15),
                        _socialMediaIcons(), // Social Media Icons
                        const SizedBox(height: 20),
                        const Text(
                          "or use your email account",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _emailController,
                                hintText: "Email",
                                icon: Icons.email,
                                isPassword: false,
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _passwordController,
                                hintText: "Password",
                                icon: Icons.lock,
                                isPassword: true,
                              ),
                              _rememberMeSwitch(), // Remember Me Switch
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _login,
                                child: const Text('LOGIN'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue, // Changed from primary to backgroundColor
                                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignUpScreen()),
                                  );
                                },
                                child: const Text(
                                  "Don't have an account? Register here",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  // Handle forgot password
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to create text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  // Social Media Icons Row
  Widget _socialMediaIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton("assets/images/facebook.png"),
        const SizedBox(width: 20),
        _buildIconButton("assets/images/twitter.png"),
        const SizedBox(width: 20),
        _buildIconButton("assets/images/google.png"),
      ],
    );
  }

  // Helper method to create icon buttons for social media
  Widget _buildIconButton(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Handle social login (optional)
      },
      child: CircleAvatar(
        backgroundImage: AssetImage(imageUrl),
        radius: 25,
      ),
    );
  }

  // Remember Me Switch
  Widget _rememberMeSwitch() {
    return SwitchListTile(
      title: const Text('Remember Me'),
      value: rememberMe,
      activeColor: Colors.blue,
      onChanged: (bool value) {
        setState(() {
          rememberMe = value;
        });
      },
    );
  }
}
