import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/user_service.dart';

class UserHome extends StatefulWidget {
  final User user;

  const UserHome({super.key, required this.user});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  late User user;
  final CourseService _courseService = CourseService();
  UserService userService = UserService();
  late Stream<List<Map<String, dynamic>>> _coursesStream;

  @override
  void initState() {
    super.initState();
    user = widget.user;
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
                        const SizedBox(height: 8),
                        Text(
                          'Department: ${course['departmentName']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Year: ${course['year']}',
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
      
    );
  }
}
