import 'package:flutter/material.dart';

class QuizAttemptScreen extends StatelessWidget {
  final String courseId;
  final String userId;

  // Constructor to receive parameters
  const QuizAttemptScreen({
    super.key,
    required this.courseId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // Use courseId and userId here
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Attempt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course ID: $courseId',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'User ID: $userId',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            // Other UI elements for quiz attempt
          ],
        ),
      ),
    );
  }
}
