import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherViewSubmissionsScreen extends StatelessWidget {
  final String assignmentId;

  const TeacherViewSubmissionsScreen({super.key, required this.assignmentId});

  Future<List<Map<String, dynamic>>> fetchSubmissions() async {
    final submissions = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('assignmentId', isEqualTo: assignmentId)
        .get();

    return submissions.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submissions')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSubmissions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No submissions found.'));
          }

          final submissions = snapshot.data!;
          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final submission = submissions[index];
              return ListTile(
                title: Text('Student: ${submission['studentName']}'),
                subtitle: Text('File: ${submission['fileUrl']}'),
              );
            },
          );
        },
      ),
    );
  }
}
