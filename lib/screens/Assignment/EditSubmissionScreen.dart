import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class EditSubmissionScreen extends StatefulWidget {
  final String submissionId;

  const EditSubmissionScreen({super.key, required this.submissionId});

  @override
  State<EditSubmissionScreen> createState() => _EditSubmissionScreenState();
}

class _EditSubmissionScreenState extends State<EditSubmissionScreen> {
  File? selectedFile;

  Future<void> updateSubmission() async {
    if (selectedFile != null) {
      final fileName = selectedFile!.path.split('/').last;
      final ref = FirebaseStorage.instance.ref('Submissions/$fileName');
      await ref.putFile(selectedFile!);

      final fileUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('Submissions')
          .doc(widget.submissionId)
          .update({'fileUrl': fileUrl});
    }
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Choose File'),
            ),
            if (selectedFile != null) Text(selectedFile!.path),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateSubmission();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Submission updated!')),
                );
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
