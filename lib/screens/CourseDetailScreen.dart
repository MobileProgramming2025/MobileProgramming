import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/QuizTrail/QuizListScreen.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_creation_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments (courseId and courseName)
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
              'Manage Course: $courseName', // Display course name instead of ID
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
                // Navigate to add assignment screen with courseId
                Navigator.pushNamed(context, '/add_assignment',
                    arguments: courseId);
              },
              child: const Text('Add Assignment'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to view quizzes screen with courseId
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
