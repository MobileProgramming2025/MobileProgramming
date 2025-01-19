import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';
import 'package:mobileprogramming/services/CourseService.dart';
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
  List<Map<dynamic, dynamic>> coursesList = [];

  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  // final _form = GlobalKey<FormState>();
  late String departmentId;
  late String studentYear;
  bool isChecked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    departmentId = widget.user.departmentId!;
    studentYear = widget.user.year!;
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await _courseService
          .getCoursesByDepartmentId(departmentId)
          .first; // Get the data once
      setState(() {
        coursesList = courses
            .where((course) => studentYear == course.year)
            .map((course) => {
                  "title": course.name,
                  "isChecked": false,
                })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
      debugPrint("Error loading courses: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    departmentId = widget.user.departmentId!;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Advising",
          ),
        ),
        drawer: UserDrawer(user: widget.user),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : coursesList.isEmpty
                ? const Center(child: Text("No courses available."))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: coursesList.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: coursesList[index]["isChecked"] as bool?,
                        onChanged: (value) {
                          setState(() {
                            coursesList[index]["isChecked"] = value!;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        title: Text(
                          coursesList[index]["title"] as String,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }));
  }
}
