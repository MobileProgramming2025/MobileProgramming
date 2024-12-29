import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';

class CoursesList extends StatelessWidget {
  final List<Course> courses;

  const CoursesList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Center(
        child: Text('No courses added yet',
            style: Theme.of(context).textTheme.bodyLarge),
      );
    }
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(courses[index].name,
            style: Theme.of(context).textTheme.headlineMedium),
        
      ),
    );
  }
}
