import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_assignment_screen.dart';

class AssignmentListScreen extends StatelessWidget {
  final String courseId;

  AssignmentListScreen({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('assignments')
            .doc(courseId)
            .collection('assignments')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching assignments'));
          }

          final assignments = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return ListTile(
                title: Text(assignment['title']),
                subtitle: Text(assignment['description']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('assignments')
                        .doc(courseId)
                        .collection('assignments')
                        .doc(assignment.id)
                        .delete();
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditAssignmentScreen(
                        courseId: courseId,
                        assignmentId: assignment.id,
                        assignmentData: assignment,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditAssignmentScreen(courseId: courseId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
