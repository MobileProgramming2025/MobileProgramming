import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobileprogramming/services/SubmissionService.dart'; 

class SubmitAssignmentScreen extends StatefulWidget {
  final String assignmentId;
  final String studentId;

  const SubmitAssignmentScreen({super.key, required this.assignmentId, required this.studentId});

  @override
  _SubmitAssignmentScreenState createState() => _SubmitAssignmentScreenState();
}

class _SubmitAssignmentScreenState extends State<SubmitAssignmentScreen> {
  final SubmissionService _submissionService = SubmissionService();
  File? _file;

  void pickFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery); // Replace with file picker
    if (pickedFile != null) {
      setState(() {
        _file = File(pickedFile.path);
      });
    }
  }

  void submitFile() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file.')),
      );
      return;
    }

    try {
      // Upload file to Firebase Storage
      final fileUrl = await _submissionService.uploadFile(_file!);

      // Create submission data
      Map<String, dynamic> submissionData = {
        'assignmentId': widget.assignmentId,
        'studentId': widget.studentId,
        'fileUrl': fileUrl,
        'grade': null,
        'feedback': null,
      };

      // Save to Firestore
      await _submissionService.submitAssignment(submissionData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: Text(_file == null ? 'Pick File' : 'Change File'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitFile,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
