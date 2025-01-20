import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/UserScreens/CourseSectionsScreen.dart';
import 'package:mobileprogramming/screens/doctorScreens/ChatScreen.dart';
import 'package:mobileprogramming/screens/partials/DoctorAppBar.dart';
import 'package:mobileprogramming/screens/partials/UserBottomNavigationBar.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';

import 'package:mobileprogramming/services/CourseService.dart';
import 'package:table_calendar/table_calendar.dart';

class UserHome extends ConsumerStatefulWidget {
  final User user;
  const UserHome({super.key, required this.user});

  @override
  ConsumerState<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends ConsumerState<UserHome> {
  final CourseService _courseService = CourseService();
  bool isLoading = true;
  List<String> courses = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  late User user;
  late String userId;

  @override
  void initState() {
    super.initState();
    _fetchData();
    user = widget.user;
  }

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    userId = widget.user.id;
    final enrolledCourseStream = ref.watch(coursesProvider(userId));

    return Scaffold(
      appBar: DoctorAppBar(
        doctor: widget.user,
        appBarText: "Hello, ${widget.user.name}!",
      ),
      drawer: UserDrawerScreen(user: user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDate,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _focusedDate = focusedDay;
                      });
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      weekendDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      outsideDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground),
                      weekendTextStyle: TextStyle(color: Colors.red),
                      todayTextStyle: TextStyle(
                        color: const Color.fromARGB(255, 56, 3, 3),
                        fontWeight: FontWeight.bold,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      outsideDaysVisible: false,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "My Courses",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(0),
                child: enrolledCourseStream.when(
                  // Loading state
                  data: (courses) {
                    if (courses.isEmpty) {
                      return const Center(
                        child: Text("You don't have any enrolled courses."),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final enrolledCourses = courses[index];

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseDetailsScreen(
                                  courseId: enrolledCourses['id'],
                                  courseName: enrolledCourses['name'],
                                  courseCode: enrolledCourses['code'],
                                  userId: widget.user.id,
                                  user: widget.user,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  8.0), // Add padding for better spacing
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.book,
                                    size: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(enrolledCourses['name'],
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      'Course Code: ${enrolledCourses['code']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "All Courses",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              StreamBuilder<List<Course>>(
                stream: _courseService
                    .getCoursesByDepartmentId(widget.user.departmentId!),
                builder: (context, snapshot) {
                  // Handling different connection states
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
                        'No Courses Found in this Department',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }
                  final courses = snapshot.data!;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];

                      return Card(
                        elevation: 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book,
                              size: 50,
                            ),
                            SizedBox(height: 8),
                            Text(course.name,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                            Text('Course Code: ${course.code}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the ChatScreen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      userId: user.id,
                    )),
          );
        },
        child: Icon(Icons.chat),
        tooltip: "Chat",
      ),
      bottomNavigationBar: UserBottomNavigationBar(user: user),
    );
  }
}

// class ProgressCard extends StatelessWidget {
//   final String title;
//   final double progress;
//   final Color color;

//   const ProgressCard({
//     super.key,
//     required this.title,
//     required this.progress,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: color,
//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           LinearProgressIndicator(
//             value: progress / 100,
//             color: Colors.blueAccent,
//             backgroundColor: Colors.grey[300],
//           ),
//           SizedBox(height: 10),
//           Text(
//             "${progress.toInt()}%",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
