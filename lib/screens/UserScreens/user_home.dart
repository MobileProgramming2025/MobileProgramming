import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/Quiz/quiz_attempt_screen.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/services/user_service.dart';

class UserHome extends StatefulWidget {
  final User user;

  const UserHome({super.key, required this.user});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  late User user;
  final CourseService _courseService = CourseService();
  UserService userService = UserService();
  late Stream<List<Map<String, dynamic>>> _coursesStream;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _coursesStream = _courseService.getAllCourses();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Home"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _logout();
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('View Assignments'),
              onTap: () {
                Navigator.pushNamed(context, '/student-assignment-list');
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>( 
          // Using Stream to get real-time updates
          stream: _coursesStream,
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
                  'No Courses Found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final courses = snapshot.data!;

            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                return GestureDetector(
                  onTap: () {
                    // Navigate to the Quiz screen, passing the course ID and user ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizAttemptScreen(
                          courseId: course['id'],
                          userId: user.id, // Passing the user ID
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                            'Department: ${course['departmentName']}',
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
        ),
      ),
    );
  }
}

