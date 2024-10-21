import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:audioplayers/audioplayers.dart'; // For sound effects
import 'fileviewer.dart'; // Correct import of fileviewer.dart

class HealthFile extends StatefulWidget {
  @override
  State<HealthFile> createState() => _HealthFileState();
}

class _HealthFileState extends State<HealthFile> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _documents = []; // Store metadata for each file
  List<Map<String, dynamic>> _filteredDocuments = []; // For filtered search
  TextEditingController _searchController = TextEditingController(); // Search controller
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound effects

  @override
  void initState() {
    super.initState();
    _loadSavedFiles(); // Load saved files from Firestore
    _searchController.addListener(_filterDocuments); // Listen to search input
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller to avoid memory leaks
    super.dispose();
  }

  // Load saved files metadata from Firestore
  Future<void> _loadSavedFiles() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get current user UID
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('health_files')
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();

      setState(() {
        _documents = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _filteredDocuments = _documents; // Initially, show all documents
      });
    } catch (e) {
      print("Error loading files: $e");
    }
  }

  // Play a sound effect when the upload is successful
  Future<void> _playUploadSuccessSound() async {
    try {
      await _audioPlayer.play(AssetSource('/assets/sounds/congo.mp3')); // Ensure this file exists in your assets folder
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  // Upload a file to Firebase Storage and save its metadata in Firestore
  Future<void> _uploadToFirebase(File file, String customName) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid; // Get current user UID

      // Create a reference to the storage
      Reference storageRef =
      FirebaseStorage.instance.ref().child('health_files/$userId/$customName');

      // Upload to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata in Firestore with user ID
      await FirebaseFirestore.instance.collection('health_files').add({
        'name': customName,
        'url': downloadUrl,
        'type': file.path.endsWith('.pdf')
            ? 'pdf'
            : file.path.endsWith('.doc') || file.path.endsWith('.docx')
            ? 'doc'
            : 'image',
        'userId': userId, // Store user ID with the file
      });

      // Update the local state to show the new document
      setState(() {
        _documents.add({
          'name': customName,
          'url': downloadUrl,
          'type': file.path.endsWith('.pdf')
              ? 'pdf'
              : file.path.endsWith('.doc') || file.path.endsWith('.docx')
              ? 'doc'
              : 'image',
          'userId': userId,
        });
        _filteredDocuments = _documents; // Update the filtered list
      });

      // Play sound effect after upload success
      _playUploadSuccessSound();

      // Show a Snackbar to notify the user of the successful upload
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File "$customName" uploaded successfully!'),
          duration: Duration(seconds: 2), // Duration of the Snackbar
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error uploading file: $e");
    }
  }

  // Pick a PDF file and save it to Firebase
  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String customName = result.files.single.name;
      await _uploadToFirebase(file, customName);
    }
  }

  // Capture photo using the camera and upload it to Firebase
  Future<void> _capturePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      // Prompt user for a custom name for the image
      TextEditingController _nameController = TextEditingController();
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Name the Photo"),
            content: TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: "Enter name"),
            ),
            actions: <Widget>[
              TextButton(
                child: Text("Save"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );

      String customName = _nameController.text.isNotEmpty
          ? _nameController.text
          : DateTime.now().millisecondsSinceEpoch.toString();

      File savedImage = File(photo.path);
      await _uploadToFirebase(savedImage, customName);
    }
  }

  // Filter documents based on search query
  void _filterDocuments() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredDocuments = _documents
          .where((doc) =>
          doc['name'].toString().toLowerCase().contains(query)) // Filter by name
          .toList();
    });
  }

  // Display the list of documents (PDFs, Images, or Word files)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 211, 211, 211),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search files...',
            border: InputBorder.none,
          ),
          style: GoogleFonts.actor(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.black),
            onPressed: _pickPdf, // Pick a PDF or Word file
          ),
          IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.black),
            onPressed: _capturePhoto, // Capture photo
          ),
        ],
      ),
      body: _filteredDocuments.isEmpty
          ? Center(
        child: Text(
          "No documents available",
          style: GoogleFonts.actor(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _filteredDocuments.length,
        itemBuilder: (context, index) {
          var doc = _filteredDocuments[index];
          String fileName = doc['name'];
          String fileUrl = doc['url'];
          bool isPdf = doc['type'] == 'pdf';
          bool isImage = doc['type'] == 'image';
          bool isWord = doc['type'] == 'doc' || doc['type'] == 'docx'; // Handling Word files

          return ListTile(
            leading: isPdf
                ? Icon(Icons.picture_as_pdf, color: Colors.red)
                : isImage
                ? Icon(Icons.image, color: Colors.blue)
                : Icon(Icons.description, color: Colors.green), // Icon for Word files
            title: Text(
              fileName,
              style: GoogleFonts.actor(fontSize: 16),
            ),
            onTap: () {
              // Navigate to the file viewer page with appropriate flags
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FileViewerPage(
                    fileUrl: fileUrl,
                    isPdf: isPdf,
                    isImage: isImage,
                    isWord: isWord,
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
