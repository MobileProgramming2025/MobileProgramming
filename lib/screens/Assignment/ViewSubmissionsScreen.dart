import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSubmissionsScreen extends StatelessWidget {
  final String assignmentId;

  const ViewSubmissionsScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submissions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Submissions')
            .where('assignmentId', isEqualTo: assignmentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var submissions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              var submission = submissions[index];
              return ListTile(
                title: Text('Student ID: ${submission['studentId']}'),
                subtitle: Text(
                    'Submitted At: ${submission['submittedAt'].toDate().toString()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    // Code to download/view the file
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
