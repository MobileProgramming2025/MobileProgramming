import 'package:flutter/material.dart';

class ViewCoursesScreen extends StatefulWidget {
  const ViewCoursesScreen({super.key});

  @override
  State<ViewCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends State<ViewCoursesScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _addCourse() {
    Navigator.pushNamed(context, '/add_courses_screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Courses",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 248, 128, 18),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: Color.fromARGB(255, 248, 128, 18),
        tooltip: "Add Doctor",
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
