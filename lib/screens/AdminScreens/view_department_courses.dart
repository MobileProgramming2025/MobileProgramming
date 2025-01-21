import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';

class ViewDepartmentCoursesScreen extends ConsumerStatefulWidget {
  const ViewDepartmentCoursesScreen({super.key});

  @override
  ConsumerState<ViewDepartmentCoursesScreen> createState() =>
      _ViewDepartmentCoursesScreenState();
}

class _ViewDepartmentCoursesScreenState
    extends ConsumerState<ViewDepartmentCoursesScreen> {
  late String departmentId;

  void _enroll() {
    Navigator.pushNamed(
      context,
      '/enroll_instructor',
      arguments: departmentId,
    ); // Pass the same departmentId
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch the departmentId safely using ModalRoute
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args == null) {
      // Handle error when the departmentId is not passed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Department ID not passed')),
      );
      return; // Prevent further actions if the ID is not available
    }

    // Typecast departmentId safely
    departmentId = args as String;

    // Fetch the courses for the specific department once the departmentId is available
    ref
        .read(userCourseStateProvider.notifier)
        .fetchDepartmentCourses(departmentId);
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(userCourseStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courses.isEmpty
            ? const Center(child: Text("No Courses Found in that Department"))
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
