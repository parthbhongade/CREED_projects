import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import your login screen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<Map<String, dynamic>> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        // Handle the case where the document does not exist
        return {'username': 'N/A', 'email': 'N/A'};
      }
    }
    return {'username': 'N/A', 'email': 'N/A'}; // Return default values if no user is logged in
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Log the user out
      // Navigate to the Login Screen after logging out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle any errors during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!;
          final username = userData['username'] ?? 'N/A';
          final email = userData['email'] ?? 'N/A';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    // Add functionality to change profile picture
                  },
                  child: const CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage('assets/images/user.JPG'),
                  ),
                ),
                const SizedBox(height: 20),
                itemProfile('Username', username, CupertinoIcons.person),
                const SizedBox(height: 10),
                itemProfile('Email', email, CupertinoIcons.mail),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Edit Profile Screen or open dialog
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.bebasNeue(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _logout(context), // Logout when pressed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Optional: Change button color
                      padding: const EdgeInsets.all(15),
                    ),
                    child: Text(
                      'Log Out',
                      style: GoogleFonts.bebasNeue(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget itemProfile(String title, String subtitle, IconData iconData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.bebasNeue(fontSize: 18),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.bebasNeue(fontSize: 16),
        ),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
      ),
    );
  }
}
