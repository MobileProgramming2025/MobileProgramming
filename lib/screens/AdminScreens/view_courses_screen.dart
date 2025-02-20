import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_courses_screen.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ViewCoursesScreen extends ConsumerStatefulWidget {
  final User admin;
  const ViewCoursesScreen({super.key, required this.admin});

  @override
  ConsumerState<ViewCoursesScreen> createState() => _ViewCoursesScreenState();
}

class _ViewCoursesScreenState extends ConsumerState<ViewCoursesScreen> {
  final CourseService _courseService = CourseService();
  final DepartmentService departmentService = DepartmentService();

  @override
  void initState() {
    super.initState();
    ref.read(courseStateProvider.notifier).fetchAllCourses();
  }

  Future<void> _deleteCourse(String courseId) async {
    try {
      // Use the provider to handle course removal
      await ref
          .read(courseStateProvider.notifier)
          .deleteCourse(courseId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course removed successfully!')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove course: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(courseStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Courses"),
      ),
      drawer: AdminDrawer(user: widget.admin),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courses.isEmpty
            ? const Center(child: Text("No Courses Found"))
            : ListView.builder(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  course.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Course Code: ${course.code}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Year: ${course.year}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteCourse(course.id);
                                },
                                color: Colors.red,
                                iconSize: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCoursesScreen(admin: widget.admin),
            ),
          );
        },
        tooltip: "Add Courses",
        child: const Icon(Icons.add),
      ),
    );
  }
}
