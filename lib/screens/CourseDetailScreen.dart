import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/QuizTrail/QuizListScreen.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_creation_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String courseId = arguments['id'];
    final String courseName = arguments['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Course: $courseName',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizCreationScreen(
                      courseId: courseId,
                    ),
                  ),
                );
              },
              child: const Text('Add Quiz'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AssignmentListScreen(courseId: courseId)),
                );
              },
              child: const Text('Add Assignment'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizListScreen(
                      courseId: courseId,
                    ),
                  ),
                );
              },
              child: const Text('View All Quizzes'),
            ),
          ],
        ),
      ),
    );
  }
}
