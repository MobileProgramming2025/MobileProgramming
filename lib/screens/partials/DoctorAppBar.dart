import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprogramming/models/databaseHelper.dart';
import 'package:mobileprogramming/models/user.dart';

class DoctorAppBar extends StatefulWidget implements PreferredSizeWidget{
  final User doctor;
  final String appBarText;

  const DoctorAppBar({super.key, required this.doctor, required this.appBarText});

  @override
  State<DoctorAppBar> createState() => _DoctorAppBarState();
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DoctorAppBarState extends State<DoctorAppBar> {
  File? _profileImage;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.appBarText,
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
                        child: Icon(Icons.account_circle, size: 20),
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
    );
  }
}
