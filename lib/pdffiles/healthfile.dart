import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'fileviewer.dart'; // Correct import of fileviewer.dart

class HealthFile extends StatefulWidget {
  @override
  State<HealthFile> createState() => _HealthFileState();
}

class _HealthFileState extends State<HealthFile> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _documents = []; // Store metadata for each file

  @override
  void initState() {
    super.initState();
    _loadSavedFiles(); // Load saved files from Firestore
  }

  // Load saved files metadata from Firestore
  Future<void> _loadSavedFiles() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('health_files').get();
      setState(() {
        _documents = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error loading files: $e");
    }
  }

  // Upload a file to Firebase Storage and save its metadata in Firestore
  Future<void> _uploadToFirebase(File file, String customName) async {
    try {
      // Create a reference to the storage
      Reference storageRef =
      FirebaseStorage.instance.ref().child('health_files/$customName');

      // Upload to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save metadata in Firestore
      await FirebaseFirestore.instance.collection('health_files').add({
        'name': customName,
        'url': downloadUrl,
        'type': file.path.endsWith('.pdf')
            ? 'pdf'
            : file.path.endsWith('.doc') || file.path.endsWith('.docx')
            ? 'doc'
            : 'image',
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
        });
      });
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

  // Display the list of documents (PDFs, Images, or Word files)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 211, 211, 211),
        title: Text(
          "Health Files",
          style: GoogleFonts.bebasNeue(fontSize: 30),
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
      body: _documents.isEmpty
          ? Center(
        child: Text(
          "No documents available",
          style: GoogleFonts.actor(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          var doc = _documents[index];
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
