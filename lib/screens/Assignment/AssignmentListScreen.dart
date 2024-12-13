import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/AssignmentService.dart'; // Import your service

class AssignmentListScreen extends StatelessWidget {
  final AssignmentService _assignmentService = AssignmentService();

  AssignmentListScreen({super.key}); // Backend service instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _assignmentService.fetchAssignments('sampleCourseId'), // Replace with actual courseId
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assignments available.'));
          }

          final assignments = snapshot.data!;

          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
              return ListTile(
                title: Text(assignment['title']),
                subtitle: Text('Due: ${assignment['dueDate']}'),
                onTap: () {
                  // Navigate to detailed assignment page
                },
              );
            },
          );
        },
      ),
    );
  }
}
