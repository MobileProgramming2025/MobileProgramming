import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/services/user_service.dart';

class ViewInstructorCoursesScreen extends StatefulWidget {
  const ViewInstructorCoursesScreen({super.key});

  @override
  State<ViewInstructorCoursesScreen> createState() {
    return _ViewInstructorCoursesScreenState();
  }
}

class _ViewInstructorCoursesScreenState extends State<ViewInstructorCoursesScreen> {
  final UserService _userService = UserService();
  late String doctorId;
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      _logout();
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
            color: Theme.of(context).colorScheme.onSurface, // Title text color
          ),
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, // Content text color
          ),
        ),
        backgroundColor: Theme.of(context).dialogBackgroundColor, // Dialog background color
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User does not want to log out
            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Button color
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User wants to log out
            child: Text("Logout", style: TextStyle(color: Theme.of(context).colorScheme.primary)), // Button color
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log out: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    doctorId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _userService.fetchEnrolledCoursesByUserId(doctorId),
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
                child: Text(
                  'You don\'t have any enrolled courses',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final courses = snapshot.data!;

            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final user = courses[index];
                final enrolledCourses = user['enrolled_courses'];

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: enrolledCourses.length,
                  itemBuilder: (context, index) {
                    final course = enrolledCourses[index];

                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/view_courses_details',
                          arguments: {
                            'id': course['id'], // Pass course ID
                            'name': course['name'], // Pass course name
                          },
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course['name'],
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Course Code: ${course['code']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Year: ${course['year']}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 5),
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800] // Dark mode card color
              : Colors.white, // Light mode card color
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
              ? Colors.blueAccent // Dark mode selected item color
              : Colors.indigo, // Light mode selected item color
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey // Dark mode unselected item color
              : Colors.orange, // Light mode unselected item color
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.house_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
            BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: "Logout"),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
