import 'package:flutter/material.dart';

class StaticTextSection extends StatelessWidget {
  const StaticTextSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: const [
          Text(
            'Welcome to the Moodle Learning Platform',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Enhance your learning experience with a variety of courses, resources, '
            'and tools to help you achieve academic success. Explore subjects across '
            'multiple disciplines and connect with a global community of learners.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
