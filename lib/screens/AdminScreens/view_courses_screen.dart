import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Department.dart';
// import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';
// import 'package:mobileprogramming/services/user_service.dart';

class ViewCoursesScreen extends StatefulWidget {
  const ViewCoursesScreen({super.key});

  @override
  State<ViewCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends State<ViewCoursesScreen> {
  final CourseService _courseService = CourseService();
  // final UserService userService = UserService();
  final DepartmentService departmentService =DepartmentService();
  late Stream<List<Map<String, dynamic>>> _coursesStream;

  @override
  void initState() {
    super.initState();
    _coursesStream = _courseService.getAllCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          // Using Stream to get real-time updates
          stream: _coursesStream,
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
                // final Stream<User?> drStream = userService.getUserByID(course['drId']);
                // final Stream<User?> taStream = userService.getUserByID(course['taId']);
                final Stream<Department?> departmentStream = departmentService.getDepartmentByID(course['departmentId']);

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
                          course['name'],
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Course Code: ${course['code']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),

                        // StreamBuilder<User?>(
                        //   stream: drStream,
                        //   builder: (context, snapshot) {
                        //     final User? user = snapshot.data;
                        //     return Text('Doctor: ${user?.name}',
                        //         style: Theme.of(context).textTheme.bodyLarge);
                        //   },
                        // ),
                        // const SizedBox(height: 8),
                        // StreamBuilder<User?>(
                        //   stream: taStream,
                        //   builder: (context, snapshot) {
                        //     final User? user = snapshot.data;
                        //     return Text(
                        //       'Teaching Assistant: ${user?.name}',
                        //       style: Theme.of(context).textTheme.bodyLarge,
                        //     );
                        //   }
                        // ),
                        // const SizedBox(height: 8),
                        StreamBuilder<Department?>(
                          stream: departmentStream,
                          builder: (context, snapshot) {
                            final Department? dep = snapshot.data;
                            return Text(
                              'Department: ${dep?.name}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            );
                          }
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Year: ${course['year']}',
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
