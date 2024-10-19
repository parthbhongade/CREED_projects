import 'package:billstore_2/billsections.dart';
import 'package:billstore_2/electricpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'pdffiles/healthfile.dart';

class screen1 extends StatefulWidget {
  @override
  State<screen1> createState() => _screen1State();
}

class _screen1State extends State<screen1> {
  List mydomain = [
    ["ELECTRICITY", "assets/images/gadgets.png"],
    ["HEALTH", "assets/images/healthcare.png"],
    ["HARDWARE", "assets/images/tools.png"],
    ["MORE", "assets/images/more.png"]
  ];

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  // Open a dialog to create a new domain
  Future<void> _openCreateDomainDialog() async {
    TextEditingController _domainController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Create New Domain"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _domainController,
                decoration: InputDecoration(hintText: "Enter domain name"),
              ),
              const SizedBox(height: 10),
              _pickedImage == null
                  ? Text("No image selected")
                  : Image.file(_pickedImage!, height: 100), // Show selected image
              TextButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _pickedImage = File(image.path);
                    });
                  }
                },
                child: Text("Select Image"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String domainName = _domainController.text.trim();
                if (domainName.isNotEmpty && _pickedImage != null) {
                  setState(() {
                    mydomain.add([domainName, _pickedImage!.path]);
                  });
                  _domainController.clear();
                  _pickedImage = null;
                }
                Navigator.of(context).pop();
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Custom app bar
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0), // Left padding for menu icon
                  child: Image.asset(
                    "assets/images/menu.png",
                    width: 20,
                    height: 20,
                  ),
                ),
                const Padding(
                  padding: const EdgeInsets.only(right: 16.0), // Right padding for person icon
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome back", style: GoogleFonts.actor(fontSize: 25)),
                  Text("DOC STORE", style: GoogleFonts.bebasNeue(fontSize: 80)),
                ],
              ),
            ),

            // Grid for storing PDFs and other documents
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                itemCount: mydomain.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1 / 1.2),
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      switch (index) {
                        case 0:
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => electricpage()),
                          );
                          break;
                        case 1:
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => HealthFile()),
                          );
                          break;
                      }
                    },
                    child: billsection(
                      domains: mydomain[index][0],
                      path: mydomain[index][1],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button to add a new domain
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDomainDialog, // Open the domain creation dialog
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}
