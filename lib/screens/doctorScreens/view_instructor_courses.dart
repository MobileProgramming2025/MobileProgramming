import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';

class ViewInstructorCoursesScreen extends ConsumerStatefulWidget {
  const ViewInstructorCoursesScreen({super.key});

  @override
  ConsumerState<ViewInstructorCoursesScreen> createState() {
    return _ViewInstructorCoursesScreenState();
  }
}

class _ViewInstructorCoursesScreenState extends ConsumerState<ViewInstructorCoursesScreen> {
  late String doctorId; // ID of the doctor (instructor)

  @override
  Widget build(BuildContext context) {
    doctorId = ModalRoute.of(context)!.settings.arguments as String;

    // Fetch the stream of courses using Riverpod
    final courseStream = ref.watch(coursesProvider(doctorId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courseStream.when(
          // Loading state
          data: (courses) {
            if (courses.isEmpty) {
              return const Center(
                child: Text("You don't have any enrolled courses."),
              );
            }
            // Display courses if data is not empty
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final user = courses[index];
                final enrolledCourses = user['enrolled_courses'] as List;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: enrolledCourses.length,
                  itemBuilder: (context, courseIndex) {
                    final course = enrolledCourses[courseIndex];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/view_courses_details',
                          arguments: {
                            'id': course['id'], // Pass course ID
                            'name': course['name'], // Pass course name
                          },
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
