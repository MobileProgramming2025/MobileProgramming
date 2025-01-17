import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/databaseHelper.dart';
import 'package:mobileprogramming/models/user.dart';
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
  @override
  void initState() {
    super.initState();
    // Initialize the doctor instance from the widget's doctor property
    doctor = widget.doctor;
     if (doctor.profileImagePath != null) {
      _profileImage = File(doctor.profileImagePath!);
    }
  }
Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        doctor = doctor.copyWith(profileImagePath: pickedFile.path);
        // Save the updated profile image path to SQFLite
        _saveProfileImagePath(pickedFile.path);
      });
    }
  }
   Future<void> _saveProfileImagePath(String path) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateProfileImagePath(doctor.id, path);
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
             _profileImage != null
                ? CircleAvatar(
                    backgroundImage: FileImage(_profileImage!),
                    radius: 50,
                  )
                : CircleAvatar(
                    child: Icon(Icons.person),
                    radius: 50,
                  ),
            SizedBox(height: 16),
            Text(
              'Name: ${doctor.name}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Email: ${doctor.email}',
              style: TextStyle(
                fontSize: 16
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Role: ${doctor.role}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8), 

            Text(
              'Department: ${doctor.departmentId}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
             SizedBox(height: 8),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Edit Profile Image'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle edit profile
              },
              child: Text('Edit Profile')
            ),       
          ],
        ),
      ),
    );
  }
}