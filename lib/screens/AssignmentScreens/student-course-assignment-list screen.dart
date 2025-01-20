import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/ui-assignment-details.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';

class StudentCourseAssignmentListScreen extends StatefulWidget {
  final User user;
  final String courseId; // Added courseId parameter

  const StudentCourseAssignmentListScreen({
    super.key,
    required this.user,
    required this.courseId, // Add this line
  });

  @override
  State<StudentCourseAssignmentListScreen> createState() =>
      _StudentAssignmentListScreenState();
}

class _StudentAssignmentListScreenState
    extends State<StudentCourseAssignmentListScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // No need for _fetchEnrolledCourses since we're focusing on a specific course
    _isLoading = false; // Directly set loading to false after initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
      ),
      drawer: UserDrawerScreen(user: widget.user),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('assignments')
                  .where('courseId', isEqualTo: widget.courseId) // Filter by courseId
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'No assignments found for this course.',
                    style: TextStyle(color: Colors.black),
                  ));
                }

                final assignments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(assignment['title']),
                        subtitle: Text(
                            'Due: ${assignment['dueDateTime'].toDate()}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignmentDetailScreen(
                                assignmentId: assignment.id,
                                assignmentData: assignment.data()
                                    as Map<String, dynamic>,
                              ),
                            ),
                          );
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
