import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_attempt_screen.dart';
import 'package:mobileprogramming/models/user.dart';

class CourseDetailsScreen extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String userId;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.userId,
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
                Navigator.pushNamed(
                  context,
                  '/student-assignment-list', // Ensure the route for the assignments screen is correct
                  arguments: {'courseId': courseId, 'userId': userId},
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
