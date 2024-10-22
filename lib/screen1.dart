import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile.dart';
import 'package:billstore_2/billsections.dart';
import 'package:billstore_2/electricpage.dart';
import 'package:billstore_2/pdffiles/healthfile.dart';
import 'harwarefile.dart';


class Screen1 extends StatefulWidget {
  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> with TickerProviderStateMixin {
  List mydomain = [
    ["ELECTRICITY", "assets/images/gadgets.png"],
    ["HEALTH", "assets/images/healthcare.png"],
    ["HARDWARE", "assets/images/tools.png"],
    ["MORE", "assets/images/more.png"]
  ];

  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  bool _isTextVisible = false;
  bool _isCardAnimated = false;

  @override
  void initState() {
    super.initState();
    // Trigger the text animation
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _isTextVisible = true;
      });
    });

    // Trigger the card animation
    Future.delayed(Duration(milliseconds: 2000), () {
      setState(() {
        _isCardAnimated = true;
      });
    });
  }

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
                  : Image.file(_pickedImage!, height: 100),
              TextButton(
                onPressed: () async {
                  final XFile? image =
                  await _picker.pickImage(source: ImageSource.gallery);
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
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Image.asset(
                    "assets/images/menu.png",
                    width: 20,
                    height: 20,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated "Welcome back" text with fade-in and scale effect
                  AnimatedOpacity(
                    opacity: _isTextVisible ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: AnimatedScale(
                      scale: _isTextVisible ? 1.0 : 0.8,
                      duration: Duration(seconds: 1),
                      child: Text("Welcome back",
                          style: GoogleFonts.actor(fontSize: 25)),
                    ),
                  ),
                  // Animated "DOC STORE" text with fade-in and scale effect
                  AnimatedOpacity(
                    opacity: _isTextVisible ? 1.0 : 0.0,
                    duration: Duration(seconds: 1),
                    child: AnimatedScale(
                      scale: _isTextVisible ? 1.0 : 0.8,
                      duration: Duration(seconds: 1),
                      child: Text("DOC STORE",
                          style: GoogleFonts.bebasNeue(fontSize: 80)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(10),
                itemCount: mydomain.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 1 / 1.2),
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedScale(
                    scale: _isCardAnimated ? 1.0 : 0.9,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: InkWell(
                      radius: 50,
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        switch (index) {
                          case 0:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ElectricityBill()), // page routing to another page (electricity)
                            );
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HealthFile()),
                            );
                            break;
                          case 2:
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HardwareBill()),
                            );
                        }
                      },
                      child: Hero(
                        tag: mydomain[index][0],
                        child: billsection(
                          domains: mydomain[index][0],
                          path: mydomain[index][1],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDomainDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }
}