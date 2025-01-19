import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewSubmissionScreen extends StatefulWidget {
  final String assignmentId;

  const ViewSubmissionScreen({Key? key, required this.assignmentId}) : super(key: key);

  @override
  _ViewSubmissionScreenState createState() => _ViewSubmissionScreenState();
}

class _ViewSubmissionScreenState extends State<ViewSubmissionScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _submissionId;

  @override
  void initState() {
    super.initState();
    _fetchSubmission();
  }

  Future<void> _fetchSubmission() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final query = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentId', isEqualTo: widget.assignmentId)
          .where('userId', isEqualTo: userId)
          .get();

      if (query.docs.isNotEmpty) {
        final submission = query.docs.first;
        _submissionId = submission.id;
        _notesController.text = submission['notes'];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load submission: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveSubmission() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some notes before saving.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final submissionData = {
        'notes': _notesController.text.trim(),
        'submittedAt': Timestamp.now(),
      };

      if (_submissionId != null) {
        // Update existing submission
        await FirebaseFirestore.instance
            .collection('submissions')
            .doc(_submissionId)
            .update(submissionData);
      } else {
        // Create a new submission if none exists
        submissionData.addAll({
          'assignmentId': widget.assignmentId,
          'userId': userId,
        });
        await FirebaseFirestore.instance.collection('submissions').add(submissionData);
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission saved successfully!')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save submission: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Submission'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Edit Notes',
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSubmission,
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
