import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/Quiz/quiz_attempt_screen.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/partials/edit_profile.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/auth_service.dart';

class StudentProfile extends StatefulWidget {
  final User user;

  const StudentProfile({super.key, required this.user});

  @override
  State<StudentProfile> createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  late User user;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final CourseService _courseService = CourseService();
  late Stream<List<Map<String, dynamic>>> _enrolledCoursesStream;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _enrolledCoursesStream = _courseService.fetchEnrolledCoursesByUserId(user.id);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _logout() async {
    final AuthService authService = AuthService();
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await authService.logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildProfileCard(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
             ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserHome(user: user,),
                            ),
                          );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                Navigator.pop(context); 
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text("View Assignments"),
              onTap: () {
                Navigator.pushNamed(context, '/student-assignment-list');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.account_circle, size: 50)
                      : null,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              user.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildProfileCard("Email", user.email),
            _buildProfileCard("Role", user.role),
            SizedBox(height: 20.0),
          ]))
    );
  }
}
