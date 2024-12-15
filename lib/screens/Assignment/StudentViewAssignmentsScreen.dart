import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/screens/Assignment/EditSubmissionScreen.dart';
import 'package:mobileprogramming/screens/Assignment/SubmitAssignmentScreen.dart';

class StudentViewAssignmentsScreen extends StatelessWidget {
  final String courseId;
  final String studentId;

  const StudentViewAssignmentsScreen({
    super.key,
    required this.courseId,
    required this.studentId,
  });

  Future<List<Map<String, dynamic>>> fetchAssignments() async {
    final assignments = await FirebaseFirestore.instance
        .collection('Assignments')
        .where('courseId', isEqualTo: courseId)
        .get();

    final submissions = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('studentId', isEqualTo: studentId)
        .get();

    final submissionStates = Map.fromEntries(submissions.docs.map((doc) =>
        MapEntry(doc['assignmentId'], {'submitted': true, 'id': doc.id})));

    return assignments.docs.map((doc) {
      final data = doc.data();
      return {
        ...data,
        'state': submissionStates[data['id']] ?? {'submitted': false},
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAssignments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assignments found.'));
          }

          final assignments = snapshot.data!;
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              final state = assignment['state'];

              return ListTile(
                title: Text(assignment['title']),
                subtitle: Text('Due: ${assignment['dueDate']}'),
                trailing: state['submitted']
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditSubmissionScreen(
                                    submissionId: state['id'],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('Submissions')
                                  .doc(state['id'])
                                  .delete();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Submission deleted!')),
                              );
                            },
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SubmitAssignmentScreen(
                                assignmentId: assignment['id'],
                                studentId: studentId,
                              ),
                            ),
                          );
                        },
                        child: const Text('Submit'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
