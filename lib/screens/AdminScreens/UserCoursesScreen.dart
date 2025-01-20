import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/partials/UserBottomNavigationBar.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';

class UserCoursesScreen extends ConsumerStatefulWidget {
  final User user;
  const UserCoursesScreen({super.key, required this.user});

  @override
  ConsumerState<UserCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends ConsumerState<UserCoursesScreen> {
  final DepartmentService departmentService = DepartmentService();
  // late Stream<List<Map<String, dynamic>>> _departmentsStream;
  late String userId;


  void _removeCourse(){

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
    final courseStream = ref.watch(coursesProvider(userId));

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
                          onPressed: _removeCourse,
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
