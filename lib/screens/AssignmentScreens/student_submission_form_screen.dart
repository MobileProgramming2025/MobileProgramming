import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you have this dependency in your pubspec.yaml
import 'package:firebase_auth/firebase_auth.dart'; // To get the current user ID

class SubmissionFormScreen extends StatefulWidget {
  final String assignmentId;

  const SubmissionFormScreen({Key? key, required this.assignmentId}) : super(key: key);

  @override
  _SubmissionFormScreenState createState() => _SubmissionFormScreenState();
}

class _SubmissionFormScreenState extends State<SubmissionFormScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isUploading = false;

  Future<void> _submitForm() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some notes before submitting.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Prepare the submission data
      final submissionData = {
        'assignmentId': widget.assignmentId,
        'userId': userId,
        'notes': _notesController.text.trim(),
        'submittedAt': Timestamp.now(),
      };

      // Save to Firestore (submissions collection)
      await FirebaseFirestore.instance.collection('submissions').add(submissionData);

      setState(() {
        _isUploading = false;
      });

      // Navigate back or show a confirmation message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit assignment: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitForm,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
