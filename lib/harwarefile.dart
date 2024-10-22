import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pdffiles/electricbillviewer.dart'; // Ensure correct import for your file viewer

class HardwareBill extends StatefulWidget {
  @override
  State<HardwareBill> createState() => _HardwareBillState();
}

class _HardwareBillState extends State<HardwareBill> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _bills = []; // Store metadata for each bill
  List<Map<String, dynamic>> _filteredBills = []; // For filtered search
  TextEditingController _searchController = TextEditingController(); // Search controller

  @override
  void initState() {
    super.initState();
    _loadSavedBills(); // Load saved bills from Firestore
    _searchController.addListener(_filterBills); // Listen to search input
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  // Load saved bills metadata from Firestore
  Future<void> _loadSavedBills() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get current user UID
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('hardware_bills')
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();

      setState(() {
        _bills = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _filteredBills = _bills; // Initially, show all bills
      });
    } catch (e) {
      print("Error loading bills: $e");
    }
  }

  // Upload a bill to Firebase Storage and save its metadata in Firestore
  Future<void> _uploadToFirebase(File file, String customName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get current user UID

      // Create a reference to the storage
      Reference storageRef =
      FirebaseStorage.instance.ref().child('hardware_bills/$userId/$customName');

      // Upload to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata in Firestore with user ID
      await FirebaseFirestore.instance.collection('hardware_bills').add({
        'name': customName,
        'url': downloadUrl,
        'type': file.path.endsWith('.pdf') ? 'pdf' : 'image', // Assume images or PDFs
        'userId': userId, // Store user ID with the file
      });

      // Update the local state to show the new bill
      setState(() {
        _bills.add({
          'name': customName,
          'url': downloadUrl,
          'type': file.path.endsWith('.pdf') ? 'pdf' : 'image',
          'userId': userId,
        });
        _filteredBills = _bills; // Update the filtered list
      });

      // Show a Snackbar to notify the user of the successful upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill "$customName" uploaded successfully!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error uploading bill: $e");
    }
  }

  // Pick a PDF file or image for the hardware bill and save it to Firebase
  Future<void> _pickBill() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      _promptForFileName(file); // Prompt the user to enter a custom name
    }
  }

  // Capture image from camera and upload it
  Future<void> _captureBillFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      _promptForFileName(file); // Prompt the user to enter a custom name
    }
  }

  // Prompt the user to enter a custom file name before uploading
  Future<void> _promptForFileName(File file) async {
    String? customName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: Text('Enter File Name'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'File Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close without saving
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text); // Return the entered name
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (customName != null && customName.isNotEmpty) {
      await _uploadToFirebase(file, customName); // Upload the file with the entered name
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File name cannot be empty!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter bills based on search query
  void _filterBills() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBills = _bills
          .where((bill) => bill['name'].toString().toLowerCase().contains(query)) // Filter by name
          .toList();
    });
  }

  // Display the list of bills (PDFs or Images)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 211, 211, 211),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search bills...',
            border: InputBorder.none,
          ),
          style: GoogleFonts.actor(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.black),
            onPressed: _captureBillFromCamera, // Capture a bill from the camera
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.black),
            onPressed: _pickBill, // Pick a PDF or image for the bill
          ),
        ],
      ),
      body: _filteredBills.isEmpty
          ? Center(
        child: Text(
          "No bills available",
          style: GoogleFonts.actor(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _filteredBills.length,
        itemBuilder: (context, index) {
          var bill = _filteredBills[index];
          String fileName = bill['name'];
          String fileUrl = bill['url'];
          bool isPdf = bill['type'] == 'pdf';
          bool isImage = bill['type'] == 'image';

          return ListTile(
            leading: isPdf
                ? Icon(Icons.picture_as_pdf, color: Colors.red)
                : Icon(Icons.image, color: Colors.blue),
            title: Text(
              fileName,
              style: GoogleFonts.actor(fontSize: 16),
            ),
            onTap: () {
              // Navigate to the file viewer page with appropriate flags
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BillViewerPage(
                    fileUrl: fileUrl,
                    isPdf: isPdf,
                    isImage: isImage,
                    isWord: false, // Assuming this example isn't for Word documents
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
