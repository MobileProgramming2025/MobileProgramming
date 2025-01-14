import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_detail_screen.dart';
import 'student_assignment_detail_screen.dart';

class StudentAssignmentListScreen extends StatefulWidget {
  @override
  _StudentAssignmentListScreenState createState() =>
      _StudentAssignmentListScreenState();
}

class _StudentAssignmentListScreenState
    extends State<StudentAssignmentListScreen> {
  List<String> _enrolledCourseIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEnrolledCourses();
  }

  Future<void> _fetchEnrolledCourses() async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      final userData = userDoc.data();
      if (userData != null && userData.containsKey('enrolledCourses')) {
        final enrolledCourses = userData['enrolledCourses'] as List<dynamic>;

        setState(() {
          _enrolledCourseIds = enrolledCourses
              .map((course) => course['id'] as String)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching enrolled courses: $e');
    setState(() {
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
                      return Center(child: Text('No assignments found.' , style: TextStyle(color: const Color.fromARGB(255, 10, 1, 0))));
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
