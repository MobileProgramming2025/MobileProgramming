import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/services/CourseService.dart';

class ViewDepartmentCoursesScreen extends StatefulWidget {
  const ViewDepartmentCoursesScreen({super.key});

  @override
  State<ViewDepartmentCoursesScreen> createState() => _ViewDepartmentCoursesScreenState();
}

class _ViewDepartmentCoursesScreenState extends State<ViewDepartmentCoursesScreen> {
  final CourseService _courseService = CourseService();
  late Stream<List<Course>> _coursesStream;
  late String departmentId;

  void _enroll() {
    _courseService.enrollInstructor();
    Navigator.pushNamed(
      context,
      '/enroll_instructor',
      arguments: departmentId,
    ); // Pass the same departmentId);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed via Navigator
    departmentId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Course>>(
          // Using Stream to get real-time updates
          stream: _courseService.getCoursesByDepartmentId(departmentId),
          builder: (context, snapshot) {
            // Handling different connection states
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
                  'No Courses Found in this Department',
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
                  elevation: 4,
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
                          'Year: ${course.year}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _enroll,
        child: Text(
          'Enroll Instructors To Courses',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
