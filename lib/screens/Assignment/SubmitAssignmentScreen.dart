import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/SubmissionService.dart';
import 'package:mobileprogramming/screens/Assignment/EditSubmissionScreen.dart';

class SubmitAssignmentScreen extends StatelessWidget {
  final SubmissionService _submissionService = SubmissionService();
  final String studentId;
  final String assignmentId;

  SubmitAssignmentScreen({super.key, required this.studentId, required this.assignmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Assignments')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _submissionService.fetchSubmissionsByStudent(studentId),
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
                title: Text(submission['assignmentTitle']),
                subtitle: Text('Submitted on: ${submission['submissionDate']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditSubmissionScreen(
                              submissionId: submission['id'],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _submissionService.deleteSubmission(submission['id']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Submission deleted!')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
