import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/UserScreens/CourseSectionsScreen.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';

import 'package:mobileprogramming/services/CourseService.dart';

class UserHome extends StatefulWidget {
  final User user;
  const UserHome({super.key, required this.user});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late User user;
  final CourseService _courseService = CourseService();
  late Stream<List<Map<String, dynamic>>> _enrolledCoursesStream;
  late String username;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _enrolledCoursesStream =
        _courseService.fetchEnrolledCoursesByUserIdSt(user.id);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      appBar: AppBar(
        title: Text("Hello, ${widget.user.name}"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: UserDrawer(user: widget.user),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _enrolledCoursesStream,
          builder: (context, snapshot) {
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
                child: Text('No Enrolled Courses Found'),
              );
            }

            final courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  child: ListTile(
                    title: Text(course['name']),
                    subtitle: Text('Code: ${course['code']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailsScreen(
                            courseId: course['id'],
                            courseName: course['name'],
                            courseCode: course['code'],
                            userId: user.id,
                            user: user,
                          ),
                        ),
                      );
                    },
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
