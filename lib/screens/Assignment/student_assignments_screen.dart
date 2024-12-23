import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  final String courseId;

  const StudentAssignmentsScreen({super.key, required this.courseId});

  @override
  State<StudentAssignmentsScreen> createState() => _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  String? _uploadedFileUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .where('courseId', isEqualTo: widget.courseId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No assignments available.'));
          }

          final assignments = snapshot.data!.docs;

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];

              return Card(
                elevation: 3,
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(assignment['title']),
                  subtitle: Text(
                    'Due: ${DateTime.parse(assignment['dueDateTime'].toDate().toString())}',
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssignmentDetailScreen(
                        assignmentId: assignment.id,
                        title: assignment['title'],
                        description: assignment['description'],
                        dueDateTime: (assignment['dueDateTime'] as Timestamp).toDate(),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;
  final String title;
  final String description;
  final DateTime dueDateTime;

  const AssignmentDetailScreen({
    super.key, 
    required this.assignmentId,
    required this.title,
    required this.description,
    required this.dueDateTime,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  File? _selectedFile;
  String? _uploadedFileUrl;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    final fileName = 'submissions/${widget.assignmentId}/${DateTime.now().toIso8601String()}_${_selectedFile!.path.split('/').last}';
    final storageRef = FirebaseStorage.instance.ref().child(fileName);

    try {
      final uploadTask = storageRef.putFile(_selectedFile!);
      final snapshot = await uploadTask.whenComplete(() => {});
      final fileUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _uploadedFileUrl = fileUrl;
      });

      await FirebaseFirestore.instance
          .collection('submissions')
          .doc(widget.assignmentId)
          .set({
        'assignmentId': widget.assignmentId,
        'fileUrl': fileUrl,
        'submittedAt': Timestamp.now(),
        'studentId': 'sample_student_id', // Replace with the actual student ID
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission uploaded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload submission: $e')));
    }
  }

  Future<void> _deleteSubmission() async {
    try {
      final docRef = FirebaseFirestore.instance.collection('submissions').doc(widget.assignmentId);

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await FirebaseStorage.instance.refFromURL(docSnapshot['fileUrl']).delete();
        await docRef.delete();
      }

      setState(() {
        _uploadedFileUrl = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission deleted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete submission: $e')));
    }
  }

  Future<void> _editSubmission() async {
    await _pickFile();
    if (_selectedFile != null) {
      await _uploadFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16),
            Text('Due Date: ${widget.dueDateTime}'),
            SizedBox(height: 32),
            _uploadedFileUrl == null
                ? Text('No submission uploaded.')
                : Text(
                    'Uploaded File: ${_uploadedFileUrl!.split('/').last}',
                    style: TextStyle(color: Colors.green),
                  ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Choose File'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _uploadFile,
                  child: Text('Submit'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _editSubmission,
                  child: Text('Edit Submission'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _deleteSubmission,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete Submission'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
