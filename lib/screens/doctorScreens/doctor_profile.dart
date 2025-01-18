import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart'; // Import your User model
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DoctorProfile extends StatefulWidget {
  final User doctor;

  const DoctorProfile({super.key, required this.doctor});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  late User doctor;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  @override
  void initState() {
    super.initState();
    // Initialize the doctor instance from the widget's doctor property
    doctor = widget.doctor;
  }

  Future<void> _selectImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, // You can change to ImageSource.camera if you want
      imageQuality: 50, // Reduce image quality for better performance
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path); // Update the state with the selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _selectImage, // Open image picker on tap
              child: _profileImage != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(_profileImage!),
                      radius: 50,
                    )
                  : CircleAvatar(
                      child: Icon(Icons.person),
                      radius: 50,
                    ),
            ),
            SizedBox(height: 16),
            Text(
              'Name: ${doctor.name}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${doctor.email}',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.errorContainer,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Role: ${doctor.role}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Department: ${doctor.departmentId}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
              },
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
