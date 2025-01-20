import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/UserScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/partials/UserBottomNavigationBar.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/user_service.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class AdvisingScreen extends StatefulWidget {
  final User user;
  const AdvisingScreen({super.key, required this.user});

  @override
  State<AdvisingScreen> createState() {
    return _AdvisingScreenState();
  }
}

class _AdvisingScreenState extends State<AdvisingScreen> {
  final CourseService _courseService = CourseService();
  final UserService _userService = UserService();
  List<Map<dynamic, dynamic>> coursesList = [];
  List<String> selectedCourses = [];
  late String departmentId;
  late String studentYear;
  bool isChecked = false;
  bool isLoading = true;
  bool isEnrolledCoursesEmpty = false;

  Future<void> _checkEnrollmentStatus() async {
    bool enrolledStatus = await _courseService
        .isEnrolledCoursesEmpty(widget.user.id); // Use await here
    setState(() {
      isEnrolledCoursesEmpty = enrolledStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkEnrollmentStatus();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final user = await _userService.getUserByID(widget.user.id).first;
      if(user != null){
      departmentId= user.departmentId ?? "";
      final courses = await _courseService
          .getCoursesByDepartmentId(departmentId)
          .first; // Get the data once
      List<Map<dynamic, dynamic>> filteredCoursesList = [];

      for (var course in courses) {
        bool isTaken =
            await _courseService.isCourseTaken(course.id, widget.user.id);
        if (studentYear == course.year && !isTaken) {
          filteredCoursesList.add({
            "name": course.name,
            "code": course.code,
            "id": course.id,
            "isChecked": false,
          });
        }
      }
      
      setState(() {
        coursesList = filteredCoursesList;
        isLoading = false;
      });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
      debugPrint("Error loading courses: $e");
    }
  }

  void _enroll() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });
    try {
      if (selectedCourses.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You have to select 5 courses',
                  style: Theme.of(context).textTheme.bodyLarge)),
        );
      } else {
        for (var selectedCourseId in selectedCourses) {
          await _userService.enrollUserToCourses(
              widget.user.id, selectedCourseId);
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewCoursesScreen(user: widget.user),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selections saved successfully',
                  style: Theme.of(context).textTheme.bodyLarge)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Failed to save selections.",
                style: Theme.of(context).textTheme.bodyLarge)),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  void toggleCourseSelection(String courseId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (selectedCourses.length < 5) {
          selectedCourses.add(courseId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('You can select up to 5 courses only.',
                    style: Theme.of(context).textTheme.bodyLarge)),
          );
        }
      } else {
        // If unselected, remove from the list
        selectedCourses.remove(courseId);
      }
    });
  }

  Widget getCoursesCheckBox() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: coursesList.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          value: coursesList[index]["isChecked"] as bool?,
          onChanged: (value) {
            final courseId = coursesList[index]["id"] as String;
            toggleCourseSelection(courseId, value!);
            setState(
              () {
                coursesList[index]["isChecked"] = value;
              },
            );
          },
          activeColor: Theme.of(context).colorScheme.primary,
          title: Text(
            coursesList[index]["name"] as String,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          secondary: Icon(Icons.class_outlined),
          subtitle: Text(
            coursesList[index]["code"] as String? ?? "No Subtitle",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Advising",
        ),
      ),
      drawer: UserDrawerScreen(user: widget.user),
      body: coursesList.isEmpty
              ? Center(
                  child: Text("No courses available",
                      style: Theme.of(context).textTheme.bodyLarge),
                )
              : !isEnrolledCoursesEmpty
                  ? Center(
                      child: Text(" You already have enrolled courses",
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          getCoursesCheckBox(),
                        ],
                      ),
                    ),
      floatingActionButton: ElevatedButton(
        onPressed: _enroll,
        child: Text(
          'Enroll Courses',
          style: TextStyle(fontSize: 16),
        ),
      ),
      bottomNavigationBar: UserBottomNavigationBar(user: widget.user),
    );
  }
}