import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/screens/partials/userDrawer.dart';
import 'package:mobileprogramming/services/CourseService.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  bool isLoading = true;
  final CourseService _courseService = CourseService();
  late Future<List<Course>> _futureCourses;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
      _futureCourses = _courseService.getAllCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User home"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder(
                //Helps you handle asynchronous data fetching, db query
                future: _futureCourses,

                builder: (BuildContext context,
                    AsyncSnapshot<List<Course>> snapshot) {
                  //snapshot -> represent the current state Future
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
                      child: Text(
                        'No Courses Found',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  final courses = snapshot.data!;
                  return SizedBox(
                    child: ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Card(
                          elevation: 4, //shadow effect
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.book,
                                    size: 100, //use as much as as you need
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  course.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Course Code: ${course.code}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Doctor: ${course.drName}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Teaching Assistant: ${course.taName}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Department: ${course.departmentName}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Year: ${course.year}',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  child: Text("Enroll Course"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
