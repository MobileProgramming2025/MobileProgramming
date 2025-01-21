import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobileprogramming/models/lecture.dart';
import 'package:mobileprogramming/services/lecture_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';  // For PDF files

class LectureListScreen extends StatefulWidget {
  final String courseId;

  const LectureListScreen({super.key, required this.courseId});

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> {
  late Future<List<Lecture>> lectureList;

  @override
  void initState() {
    super.initState();
    // Fetch the lectures for the specific course
    lectureList = LectureService().getLecturesByCourse(widget.courseId);
  }

  // Function to download and display the file
  Future<void> downloadAndDisplayFile(String fileName) async {
    try {
      // Log the file name to confirm
      print("Downloading file: $fileName");
      // Fetch file from Supabase storage
      final response = await Supabase.instance.client.storage
          .from('lecture-files') // Your bucket name
          .download(fileName); // Download the file

      // Check if the response has an error
      // if (response.error != null) {
      //   throw Exception('Error downloading file: ${response.error!.message}');
      // }
      // Ensure that the response has the file data as a Uint8List
      final fileBytes = response; 
      // if (fileBytes == null) {
      //   throw Exception('File data is null');
      // }

      // Ensure that the response has the file data as a Uint8List
      // final fileBytes = response.data!;
      // final fileBytes = await response.readAsByte();
      // if (fileBytes == null) {
      //   throw Exception('File data is null');
      // }

      // Create a temporary file
      final file = File('${(await Directory.systemTemp.createTemp()).path}/$fileName');
      await file.writeAsBytes(fileBytes); // Write the file content to local storage

      // Check the file extension to decide how to display it
      final fileExtension = fileName.split('.').last.toLowerCase();

      if (fileExtension == 'pdf') {
        // Display PDF
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Lecture PDF",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            content: Container(
              height: 400,
              width: 300,
              child: PDFView(
                filePath: file.path,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      } else if (fileExtension == 'jpg' || fileExtension == 'png' || fileExtension == 'jpeg') {
        // Display image
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Lecture Image",
              style: TextStyle(
                color: Colors.black
              ),
            ),
            content: Image.file(file),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unsupported file type")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lectures'),
      ),
      body: FutureBuilder<List<Lecture>>(
        future: lectureList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No lectures found"));
          }

          final lectures = snapshot.data!;

          return ListView.builder(
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final lecture = lectures[index];
              return ListTile(
                title: Text(lecture.title),
                subtitle: Text(lecture.description),
                trailing: IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    print('File name: ${lecture.fileName}');
                    downloadAndDisplayFile(lecture.fileName); // Trigger file download and display
                  },
                ),
                onTap: () {
                  // You can navigate to a detail screen or perform other actions
                },
              );
            },
          );
        },
      ),
    );
  }
}
