import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/doctorScreens/doctor_dashboard.dart';
import 'package:mobileprogramming/screens/partials/edit_profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprogramming/models/databaseHelper.dart';
import 'package:mobileprogramming/services/user_service.dart';

class DoctorProfile extends StatefulWidget {
  final User user;

  const DoctorProfile({super.key, required this.user});

  @override
  State<DoctorProfile> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfile> {
  late User user;
  final UserService _userService = UserService();
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

  void _logout(context) async {
    _userService.logout(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(doctor: user),
            ));
        break;
      case 1:
        Navigator.pushNamed(context, '/view_Instructor_courses',
            arguments: user.id);
        break;
      case 2:
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(doctor: user),
            ));
        break;
      case 3:
        break;
      case 4:
        _logout(context);
        break;
    }
  } 


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit,color: Colors.indigo,),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()));
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
                  backgroundColor: colorScheme.secondaryContainer,
                  child: _profileImagePath == null
                      ? Icon(Icons.account_circle,
                          size: 50, color: colorScheme.onSurface)
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
                    color: colorScheme.onBackground),
              ),
              const SizedBox(height: 24),
              _buildProfileCard(
                  title: 'Name', value: user.name, colorScheme: colorScheme),
              const SizedBox(height: 12),
              _buildProfileCard(
                  title: 'Email', value: user.email, colorScheme: colorScheme),
              const SizedBox(height: 12),
              _buildProfileCard(
                  title: 'Role', value: user.role, colorScheme: colorScheme),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
     
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 5),
        height: 60,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20),
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
            BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
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
    );
  }

  Widget _buildProfileCard(
      {required String title,
      required String value,
      required ColorScheme colorScheme}) {
    return SizedBox(
      height: 80,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text('$title: ',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface)),
              Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 18, color: colorScheme.onBackground),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
