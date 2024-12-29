import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/widgets/Course/courses_list.dart';

class ViewCoursesScreen extends StatelessWidget {
  const ViewCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Courses",
        ),
      ),
      body: CoursesList( 
        
        courses: [
          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: "add_courses",
        child: const Icon(Icons.add),
      ),
    );
  }
}
