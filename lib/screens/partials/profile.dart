import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/doctorScreens/doctor_dashboard.dart';
import 'package:mobileprogramming/screens/partials/edit_profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprogramming/models/databaseHelper.dart';
import 'package:mobileprogramming/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;
  final DatabaseHelper dbHelper = DatabaseHelper();
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      String? imagePath = await dbHelper.getProfileImagePath();
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
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        await dbHelper.saveProfileImagePath(pickedFile.path);
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (error) {
      print('Error picking image: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => DoctorDashboard(doctor: user),
        ));
        break;
      case 1:
        Navigator.pushNamed(context, '/view_Instructor_courses', arguments: user.id);
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => DoctorDashboard(doctor: user),
        ));
        break;
      case 3:
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
@override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark; // Determine the current mode
  final colorScheme = Theme.of(context).colorScheme;

  return Scaffold(
    appBar: AppBar(
      title: Text('My Profile'),
      backgroundColor: colorScheme.primary, // Use primary color for AppBar
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
          },
          tooltip: 'Edit Profile',
        ),
      ],
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: colorScheme.secondaryContainer, // Background color for profile image
                child: _profileImagePath == null
                    ? Icon(Icons.account_circle, size: 50, color: colorScheme.onSurface) // Icon color to match the theme
                    : ClipOval(
                      child: Image.file(
                        File(_profileImagePath!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileCard(title: 'Name', value: user.name, colorScheme: colorScheme),
            const SizedBox(height: 12),
            _buildProfileCard(title: 'Email', value: user.email, colorScheme: colorScheme),
            const SizedBox(height: 12),
            _buildProfileCard(title: 'Role', value: user.role, colorScheme: colorScheme),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
      },
      tooltip: 'Edit Profile',
      backgroundColor: colorScheme.secondary,
      child: const Icon(Icons.edit),
    ),
    bottomNavigationBar: Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 20)],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6), // Adapt unselected item color
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.house_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: "Logout"),
        ],
        onTap: _onItemTapped,
      ),
    ),
  );
}

Widget _buildProfileCard({required String title, required String value, required ColorScheme colorScheme}) {
  return SizedBox(
    height: 80,
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface, // Match card color to theme
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text('$title: ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            Expanded(
              child: Text(value, style: TextStyle(fontSize: 18, color: colorScheme.onBackground), overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    ),
  );
}
}