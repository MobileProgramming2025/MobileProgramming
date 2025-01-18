import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/doctorScreens/doctor_profile.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/models/user.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprogramming/models/databaseHelper.dart';

class DoctorDashboard extends StatefulWidget {
  final User doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final CourseService _courseService = CourseService();

  bool isLoading = true;
  List<String> courses = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  int _currentIndex = 0;
  late User doctor;
  final DatabaseHelper dbHelper = DatabaseHelper();
  File? _profileImage;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _fetchData();
    doctor = widget.doctor;
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      String? imagePath = await DatabaseHelper().getProfileImagePath();
      if (mounted) {
        setState(() {
          _profileImagePath = imagePath;
        });
      }
    } catch (error) {
      print('Error fetching user details: $error');
    }
  }

  Future<void> _pickImage() async {
    try {
      // Allow the user to pick an image from the gallery
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Save the image path in the database
        await DatabaseHelper().saveProfileImagePath(pickedFile.path);

        // Update the UI
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (error) {
      print('Error picking image: $error');
    }
  }

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/view_Instructor_courses',
          arguments: widget.doctor.id,
        );
        (Route<dynamic> route) => false;
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDashboard(doctor: doctor),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfile(user: widget.doctor),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 4:
        _logout();
        break;
    }
  }

  void _logout() async {
    final AuthService authService = AuthService();

    // Show confirmation dialog
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Logout",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Logout",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ),
          ],
        );
      },
    );

    // Proceed with logout if user confirmed
    if (confirmLogout == true) {
      try {
        await authService.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully")),
        );
        // Navigate to login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log out: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Hello, Doctor ${widget.doctor.name}!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: _pickImage, // Make the CircleAvatar tappable
              child: Stack(
                children: [
                  // Profile Image
                  _profileImagePath == null
                      ? CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.account_circle, size: 50),
                        )
                      : CircleAvatar(
                          radius: 20,
                          backgroundImage: FileImage(File(_profileImagePath!)),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
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
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
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
                                color:
                                    Theme.of(context).colorScheme.onBackground),
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
                      "Your Courses",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _courseService
                          .fetchEnrolledCoursesByUserId(widget.doctor.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No Courses Found',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }

                        final instructorCourses = snapshot.data!;

                        // Flatten the list of courses for all users
                        final allInstructorCourses = instructorCourses
                            .expand((user) =>
                                user['enrolled_courses'] as List<dynamic>)
                            .toList();

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allInstructorCourses.length,
                          itemBuilder: (context, index) {
                            final instructorCourse =
                                allInstructorCourses[index];

                            return Card(
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
                                    Text(
                                      instructorCourse['name'],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Text(
                                        'Course Code: ${instructorCourse['code']}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      "All Courses",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<List<Course>>(
                      stream: _courseService.getCoursesByDepartmentId(
                          widget.doctor.departmentId!),
                      builder: (context, snapshot) {
                        // Handling different connection states
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No Courses Found in this Department',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          );
                        }
                        final courses = snapshot.data!;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
                                  Text(
                                    course.name,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  Text('Course Code: ${course.code}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          // Adapt background color based on theme
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850] // Dark mode background
              : Colors.grey[100], // Light mode background
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 5),
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.blueAccent
                : Colors.indigo,
            unselectedItemColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey
                : Colors.orange,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.house_rounded), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.school), label: "Courses"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle_outlined), label: "Profile"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.exit_to_app), label: "Logout"),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;

  const ProgressCard({
    super.key,
    required this.title,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress / 100,
            color: Colors.blueAccent,
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(height: 10),
          Text(
            "${progress.toInt()}%",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
