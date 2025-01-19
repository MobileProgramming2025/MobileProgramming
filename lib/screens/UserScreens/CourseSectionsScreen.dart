import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/ui-assignment-details.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_attempt_screen.dart';
import 'package:mobileprogramming/models/user.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String userId;
 final User user;
  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.userId,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Course Code: $courseCode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizAttemptScreen(
                      courseId: courseId,
                      userId: userId,
                    ),
                  ),
                );
              },
              child: Text('Quiz'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                    MaterialPageRoute(
                     builder: (context) => StudentAssignmentListScreen(user: user),
                    
                  ),
                );
              },
              child: Text('View Assignments'),
            ),
          ],
        ),
      ),
    );
  }
}
