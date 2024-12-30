import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/services/CourseService.dart';

class ViewCoursesScreen extends StatefulWidget {
  const ViewCoursesScreen({super.key});

  @override
  State<ViewCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends State<ViewCoursesScreen> {
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _futureCourses;

  @override
  void initState() {
    super.initState();
    _futureCourses = _courseService.getAllCourses();
  }


  void _deleteCourse(String id) async {
    try {
      await _courseService.deleteCourse(id);
      print(id);
      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete course: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          //Helps you handle asynchronous data fetching, db query
          future: _futureCourses,

          builder:
              (BuildContext context, AsyncSnapshot<List<Course>> snapshot) {
            //snapshot -> represent the current state Future
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No Courses Found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  elevation: 4, //shadow effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Course Code: ${course.code}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Doctor: ${course.drName}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Teaching Assistant: ${course.taName}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Department: ${course.departmentName}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Year: ${course.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.delete),
                        //   onPressed: () {
                        //     _deleteCourse(course.id);
                        //     print(course.id);
                        //   },
                        //   color: Colors.red,
                        //   iconSize: 28,
                        // ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_courses');
        },
        tooltip: "add_courses",
        child: const Icon(Icons.add),
      ),
    );
  }
}
