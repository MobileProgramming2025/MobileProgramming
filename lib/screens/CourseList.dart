import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/CourseDetailScreen.dart';
import 'package:mobileprogramming/screens/Quiz/quiz_creation_screen.dart';
import 'package:mobileprogramming/services/CourseService.dart';

class CourseListPage extends StatefulWidget {
  @override
  _CourseListPageState createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final CourseService _courseService = CourseService();
  List<Map<String, dynamic>> _courses = [];

  // Fetch courses only
  Future<void> _fetchCourses() async {
    try {
      final courses = await _courseService.getCourses();  // Fetch courses only
      setState(() {
        _courses = courses; // Store the courses in the state
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching courses: $error')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCourses();  // Fetch courses when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
             
            },
          ),
        ],
      ),
      body: _courses.isEmpty
          ? Center(child: CircularProgressIndicator())  // Show loading indicator while fetching
          : ListView.builder(
              itemCount: _courses.length,
              itemBuilder: (context, index) {
                final course = _courses[index];
                return ListTile(
                  title: Text(course['name'] ?? 'No Name'),  // Display course name
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailScreen(courseId: course['id']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
