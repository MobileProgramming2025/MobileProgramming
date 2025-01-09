import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  void _checkSubmissionStatus() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final dueDate = widget.assignmentData['dueDateTime'].toDate();
    setState(() {
      _isOverdue = DateTime.now().isAfter(dueDate);
    });

    final submissionSnapshot = await FirebaseFirestore.instance
        .collection('submissions')
        .doc(widget.assignmentId)
        .collection('studentSubmissions')
        .doc(userId)
        .get();

    if (submissionSnapshot.exists) {
      setState(() {
        _isSubmitted = true;
        _submissionUrl = submissionSnapshot.data()?['fileUrl'];
      });
    }
  }

  void _submitAssignment() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
    );

    if (result == null) return;

    final file = result.files.first;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref('submissions/${widget.assignmentId}/$userId/${file.name}');
      await ref.putData(file.bytes!);
      final fileUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(widget.assignmentId)
          .collection('studentSubmissions')
          .doc(userId)
          .set({
        'fileUrl': fileUrl,
        'submittedAt': DateTime.now(),
      });

      setState(() {
        _isSubmitted = true;
        _submissionUrl = fileUrl;
      });

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment submitted successfully!')),
      );
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit assignment: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
            Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(widget.assignmentData['description']),
            SizedBox(height: 20),
            Text('Due Date:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(dueDate.toString()),
            SizedBox(height: 20),
            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(_isOverdue ? 'Overdue' : 'On Time'),
            Text(_isSubmitted ? 'Submitted' : 'Not Submitted'),
            SizedBox(height: 20),
            _isSubmitted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Submission:', style: TextStyle(fontWeight: FontWeight.bold)),
                      InkWell(
                        onTap: () {
                          // Open the file in a browser or external app
                        },
                        child: Text(
                          'View File',
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAssignment,
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Assignment'),
                  ),
          ],
        ),
      ),
    );
  }
}
