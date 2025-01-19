import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/UserScreens/CourseSectionsScreen.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';

class ViewCoursesScreen extends ConsumerStatefulWidget {
  final User user;
  const ViewCoursesScreen({super.key, required this.user});

  @override
  ConsumerState<ViewCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends ConsumerState<ViewCoursesScreen> {
  final DepartmentService departmentService = DepartmentService();
  late Stream<List<Map<String, dynamic>>> _departmentsStream;
  late String userId;

  @override
  void initState() {
    super.initState();
    // Initializing the stream to get department data in real time
    _departmentsStream = departmentService.getAllDepartments();
  }

  @override
  Widget build(BuildContext context) {
    userId = widget.user.id;

    // Fetch the stream of courses using Riverpod
    final courseStream = ref.watch(coursesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text("My Courses"),
      ),
      drawer: UserDrawer(user: widget.user),
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
                final enrolledCourses = courses[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailsScreen(
                            courseId: enrolledCourses['id'],
                            courseName: enrolledCourses['name'],
                            courseCode: enrolledCourses['code'],
                            userId: widget.user.id,
                            user: widget.user,
                          ),
                        ),
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
                            enrolledCourses['name'],
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Course Code: ${enrolledCourses['code']}',
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
