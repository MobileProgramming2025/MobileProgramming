import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/ui-assignment-details.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';

class StudentAssignmentListScreen extends StatefulWidget {
 final User user;
  const StudentAssignmentListScreen({super.key, required this.user});

  @override
  State<StudentAssignmentListScreen> createState() =>
      _StudentAssignmentListScreenState();
}

class _StudentAssignmentListScreenState
    extends State<StudentAssignmentListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _enrolledCourses = [];
  List<String> _enrolledCourseIds = [];

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
    try {
      final userId = auth.FirebaseAuth.instance.currentUser!.uid;

      // Fetch the user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        // Check if the user is a student and has enrolled_courses
        if (userData != null && userData.containsKey('enrolled_courses')) {
          // Extract the enrolled_courses array
          final enrolledCourses = userData['enrolled_courses'] as List<dynamic>;

          // Convert to a list of maps and extract course IDs
          setState(() {
            _enrolledCourses = enrolledCourses
                .map((course) => Map<String, dynamic>.from(course))
                .toList();
            _enrolledCourseIds = _enrolledCourses
                .map((course) => course['id'] as String)
                .toList();
            _isLoading = false;
          });
        } else {
          // No enrolled courses
          setState(() {
            _enrolledCourses = [];
            _enrolledCourseIds = [];
            _isLoading = false;
          });
        }
      } else {
        // User document does not exist
        setState(() {
          _enrolledCourses = [];
          _enrolledCourseIds = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching enrolled courses: $e');
      setState(() {
        _enrolledCourses = [];
        _enrolledCourseIds = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      drawer: UserDrawer(user: widget.user),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _enrolledCourseIds.isEmpty
              ? Center(child: Text('No enrolled courses found.'))
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('assignments')
                      .where('courseId', whereIn: _enrolledCourseIds)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text(
                        'No assignments found.',
                        style: TextStyle(color: Colors.black),
                      ));
                    }

                    final assignments = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: assignments.length,
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(assignment['title']),
                            subtitle: Text(
                                'Due: ${assignment['dueDateTime'].toDate()}'),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AssignmentDetailScreen(
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
