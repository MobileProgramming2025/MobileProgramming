import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;
  final Map<String, dynamic> assignmentData;

  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    required this.assignmentData,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  bool _isSubmitting = false;
  String? _submissionUrl;
  bool _isOverdue = false;
  bool _isSubmitted = false;
PlatformFile? pickedFile;
UploadTask? uploadTask;
  @override
  void initState() {
    super.initState();
   // _initializeSubmission();
  }


Future<void> _submitAssignment() async {
  // Simulate getting userId, assignmentId, and file selection
  final userId = 'exampleUserId'; // Replace with actual user ID (from auth)
  final assignmentId = widget.assignmentId; // From the widget data
  final result = await FilePicker.platform.pickFiles();

  if (result == null || result.files.single.path == null) {
    debugPrint('No file selected');
    return;
  }

  final filePath = result.files.single.path!;
  final fileName = result.files.single.name;
  final file = File(filePath);

  debugPrint('Selected file path: $filePath');
  debugPrint('File name: $fileName');

  // Firebase Storage Reference
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('submissions/$userId/$assignmentId/$fileName');

  try {
    // Upload file to Firebase Storage
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final fileUrl = await snapshot.ref.getDownloadURL();

    debugPrint('File uploaded successfully: $fileUrl');

    // Save submission data to Firestore
    final firestoreRef = FirebaseFirestore.instance
        .collection('submissions') // Main submissions collection
        .doc(assignmentId) // Document for the specific assignment
        .collection('users') // Sub-collection for users
        .doc(userId); // User-specific submission

    await firestoreRef.set({
      'fileName': fileName,
      'fileUrl': fileUrl,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Submission saved to Firestore successfully.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment submitted successfully!')),
    );
  } catch (e) {
    debugPrint('Error during submission: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit assignment: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final dueDate = widget.assignmentData['dueDateTime'].toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignmentData['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Description:', style: TextStyle(color: Colors.black)),
            Text(widget.assignmentData['description'],
                style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            const Text('Due Date:', style: TextStyle(color: Colors.black)),
            Text(dueDate.toString(), style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            const Text('Status:', style: TextStyle(color: Colors.black)),
            Text(_isOverdue ? 'Overdue' : 'On Time',
                style: const TextStyle(color: Colors.black)),
            Text(_isSubmitted ? 'Submitted' : 'Not Submitted',
                style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            _isSubmitted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Submission:',
                          style: TextStyle(color: Colors.black)),
                      InkWell(
                        onTap: () {
                          // Open the file in a browser or external app
                        },
                        child: Text(
                          'View File :', 
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,

                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAssignment,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Assignment'),
                  ),
          ],
        ),
      ),
    );


  }
}
