import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/DoctorAppBar.dart';
import 'package:mobileprogramming/screens/partials/DoctorBottomNavigationBar.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: DoctorAppBar(doctor: widget.user, appBarText: "My Profile",),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                // onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.secondaryContainer,
                  child:
                       Icon(Icons.account_circle,
                          size: 50, color: colorScheme.onSurface)
                      // : ClipOval(
                      //     child: Image.file(
                      //       File(_profileImagePath!),
                      //       width: 100,
                      //       height: 100,
                      //       fit: BoxFit.cover,
                      //     ),
                      //   ),
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
      bottomNavigationBar: DoctorBottomNavigationBar(doctor: widget.user),
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
