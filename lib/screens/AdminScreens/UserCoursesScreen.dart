import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/CourseService.dart';

class UserCoursesScreen extends ConsumerStatefulWidget {
  final User user;
  const UserCoursesScreen({super.key, required this.user});

  @override
  ConsumerState<UserCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends ConsumerState<UserCoursesScreen> {
  // final DepartmentService departmentService = DepartmentService();
  // late Stream<List<Map<String, dynamic>>> _departmentsStream;
  final CourseService _courseService = CourseService();

  late String userId;

  void _removeCourse(String enrolledCourseId)async {
   try {
    final userId = widget.user.id; // Retrieve the user ID from the widget
    await _courseService.removeCourseFromUser(userId, enrolledCourseId); // Remove the course
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Course removed successfully!')),
    );
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to remove course: $e')),
    );
  }
  }

  @override
  void initState() {
    super.initState();
    // Initializing the stream to get department data in real time
    // _departmentsStream = departmentService.getAllDepartments();
  }

  @override
  Widget build(BuildContext context) {
    userId = widget.user.id;

    // Fetch the stream of courses using Riverpod
    final courseStream = ref.watch(userCoursesProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.name} Courses"),
      ),
      drawer: AdminDrawer(user: widget.user),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courseStream.when(
          // Loading state
          data: (courses) {
            if (courses.isEmpty) {
              return Center(
                child: Text(
                    "${widget.user.name} doesn't have any enrolled courses."),
              );
            }
            // Display courses if data is not empty
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final enrolledCourses = courses[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _removeCourse(enrolledCourses['id']);
                          },
                        ),
                      ],
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
