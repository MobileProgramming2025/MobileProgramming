import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/user_service.dart';

class ViewInstructorCoursesScreen extends StatefulWidget {
  const ViewInstructorCoursesScreen({super.key});

  @override
  State<ViewInstructorCoursesScreen> createState() {
    return _ViewInstructorCoursesScreenState();
  }
}

class _ViewInstructorCoursesScreenState
    extends State<ViewInstructorCoursesScreen> {
  final UserService _userService = UserService();
  late String doctorId;

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed via Navigator
    doctorId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          // Using Stream to get real-time updates
          stream: _userService.fetchEnrolledCoursesByUserId(doctorId),
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
                  'You don\'t have any Enrolled Courses',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final courses = snapshot.data!;

            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final user = courses[index];
                final enrolledCourses = user['enrolled_courses'];

                return ListView.builder(
                  shrinkWrap: true, // Ensures it does not take up unnecessary space
                  physics: NeverScrollableScrollPhysics(), // Prevents scrolling conflict
                  itemCount: enrolledCourses.length,
                  itemBuilder: (context, subIndex) {
                    final course = enrolledCourses[subIndex];

                    return InkWell(
                      // Makes the card clickable
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/view_courses_details',
                          arguments: course['id'], // Pass course
                        );
                      },
                      child: Card(
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
                              Text(
                                'Year: ${course['year']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
