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

  Future<void> _fetchCourses() async {
    final courses = await _courseService.getCourses();
    setState(() {
      _courses = courses;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchCourses();
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCourseScreen(onCourseAdded: _fetchCourses),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return ListTile(
            title: Text(course['name']),
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

class AddCourseScreen extends StatefulWidget {
  final Function onCourseAdded;

  AddCourseScreen({required this.onCourseAdded});

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _courseNameController = TextEditingController();
  final CourseService _courseService = CourseService();

  void _addCourse() async {
    String courseName = _courseNameController.text.trim();
    if (courseName.isNotEmpty) {
      await _courseService.addCourse(courseName);
      widget.onCourseAdded(); 
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a course name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Course')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _courseNameController,
              decoration: InputDecoration(labelText: 'Course Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addCourse,
              child: Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }
}
