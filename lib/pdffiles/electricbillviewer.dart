import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';

class BillViewerPage extends StatefulWidget {
  final String fileUrl;
  final bool isPdf;
  final bool isImage;
  final bool isWord;

  BillViewerPage({
    required this.fileUrl,
    required this.isPdf,
    required this.isImage,
    required this.isWord,
  });

  @override
  _BillViewerPageState createState() => _BillViewerPageState();
}

class _BillViewerPageState extends State<BillViewerPage> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    if (widget.isPdf || widget.isWord || widget.isImage) {
      _downloadFile();
    }
  }

  // Download file to a temporary location
  Future<void> _downloadFile() async {
    try {
      // Get the temporary directory of the device
      final dir = await getTemporaryDirectory();

      // Determine the file extension
      String extension = widget.isPdf
          ? 'pdf'
          : widget.isWord
          ? 'docx'
          : 'jpg'; // 'jpg' for images

      // Define the file path for the document
      final file = File('${dir.path}/temp.$extension');

      // Download the file from the URL
      final response = await http.get(Uri.parse(widget.fileUrl));

      // Write the downloaded data to the file
      await file.writeAsBytes(response.bodyBytes);

      // Set the local file path to display or open the file
      setState(() {
        localFilePath = file.path;
      });

      // Automatically open Word documents after download
      if (widget.isWord && localFilePath != null) {
        OpenFile.open(localFilePath!);
      }
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPdf
            ? "View PDF"
            : widget.isImage
            ? "View Image"
            : "View Document"),
      ),
      body: widget.isPdf
          ? (localFilePath == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(filePath: localFilePath!)) // Display the PDF
          : widget.isImage
          ? (localFilePath == null
          ? Center(child: CircularProgressIndicator())
          : Center(child: Image.file(File(localFilePath!)))) // Display the image
          : widget.isWord
          ? Center(child: Text("Opening Word Document...")) // Indicate that the Word doc is opening
          : Center(child: Text("Unsupported file type")), // Fallback for unsupported types
    );
  }
}
