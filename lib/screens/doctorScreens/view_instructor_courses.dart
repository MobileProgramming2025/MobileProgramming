import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/partials/DoctorAppBar.dart';
import 'package:mobileprogramming/screens/partials/DoctorBottomNavigationBar.dart';

class ViewInstructorCoursesScreen extends ConsumerStatefulWidget {
  final User doctor;
  const ViewInstructorCoursesScreen({super.key, required this.doctor});

  @override
  ConsumerState<ViewInstructorCoursesScreen> createState() {
    return _ViewInstructorCoursesScreenState();
  }
}

class _ViewInstructorCoursesScreenState
    extends ConsumerState<ViewInstructorCoursesScreen> {
  late String doctorId; // ID of the doctor (instructor)
  @override
  void initState() {
    super.initState();
    doctorId = widget.doctor.id;
    // Fetch courses for the doctor
    ref.read(userCourseStateProvider.notifier).fetchUserCourses(doctorId);
  }

  @override
  Widget build(BuildContext context) {
    // Access the state using Riverpod's Consumer widget
    final courses = ref.watch(userCourseStateProvider);

    return Scaffold(
      appBar: DoctorAppBar(
        doctor: widget.doctor,
        appBarText: "My Courses",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: courses.isEmpty
            ? const Center(
                child: Text("You don't have any enrolled courses"))
            : ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final enrolledCourses = courses[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/view_courses_details',
                        arguments: {
                          'id': enrolledCourses.id,
                          'name': enrolledCourses.name,
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
                              enrolledCourses.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Course Code: ${enrolledCourses.code}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Year: ${enrolledCourses.year}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: DoctorBottomNavigationBar(doctor: widget.doctor),
    );
  }
}
