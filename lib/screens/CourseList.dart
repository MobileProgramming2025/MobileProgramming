import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/course.dart';
import 'package:mobileprogramming/screens/CourseDetailScreen.dart';
import 'package:mobileprogramming/screens/doctorScreens/doctor_dashboard.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/screens/doctorScreens/BaseScreen.dart'; // Import BaseScreen
import 'package:mobileprogramming/models/user.dart'; // Make sure to import the User model

class CourseListPage extends StatefulWidget {
  final User doctor;

  const CourseListPage({super.key, required this.doctor}); // Accept the doctor parameter

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final CourseService _courseService = CourseService();
  final List<Course> _courses = [];
  bool _isLoading = true;

  late final StreamSubscription _courseSubscription;

  Future<void> _fetchCourses() async {
    _courseSubscription = _courseService.getAllCourses().listen(
      (courses) {
        setState(() {
          _courses.clear();
          _courses.addAll(courses.map((data) => Course.fromMap(data)));
          _isLoading = false;
        });
      },
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching courses: $error')),
        );
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _courseSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      currentIndex: 1,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(child: Text('No courses available'))
              : ListView.builder(
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return ListTile(
                      title: Text(course.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(courseId: course.id),
                          ),
                        );
                      },
                    );
                  },
                ),
      onTabTapped: (index) {
        switch (index) {
          case 0:
            // Navigate to DoctorDashboard and pass the doctor parameter
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDashboard(doctor: widget.doctor), // Pass user information
              ),
            );
            break;
          case 1:
            // Already on Courses page, no action needed
            break;
          case 2:
            // Navigate to Calendar page
            Navigator.pushNamed(context, '/calendar');
            break;
          case 3:
            // Navigate to Profile page without doctor argument
            Navigator.pushNamed(context, '/profile');
            break;
          case 4:
            // Perform Logout logic
            _logout();
            break;
        }
      },
    );
  }

  void _logout() {
    // Implement your logout logic here
  }
}
