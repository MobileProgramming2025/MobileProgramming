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
            // Enhanced "Manage Course" Header
            _buildManageCourseHeader(context, courseName),
            const SizedBox(height: 16),
            
            // **Quizzes Section**
            _buildSectionHeader(context, 'Quizzes'),
            _buildButton(
              context,
              label: 'Add Quiz',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizCreationScreen(courseId: courseId),
                  ),
                );
              },
            ),
            _buildButton(
              context,
              label: 'View All Quizzes',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizListScreen(courseId: courseId),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // **Assignments Section**
            _buildSectionHeader(context, 'Assignments'),
            _buildButton(
              context,
              label: 'Add Assignment',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AssignmentListScreen(courseId: courseId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageCourseHeader(BuildContext context, String courseName) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1), // Light background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.book, size: 28, color: Theme.of(context).colorScheme.primary), // Icon representation
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Manage Course: $courseName',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String label, required void Function() onPressed}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(label),
          ),
        ),
      ),
    );
  }
}
