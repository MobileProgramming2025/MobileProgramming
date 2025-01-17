import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/edit_profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprogramming/models/databaseHelper.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User user;

File? _profileImage;
  @override
  void initState() {
    super.initState();
    user = widget.user;
  
        if (user?.profileImagePath != null) {
      _profileImage = File(user.profileImagePath!);
    }

  }

   Future<void> _saveProfileImagePath(String path) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateProfileImagePath(user .id, path);
  }
   Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      //  if (doctor != null) {
          user = user.copyWith(profileImagePath: pickedFile.path);
          _saveProfileImagePath(pickedFile.path);
       // }
      });
    }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to the edit form
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
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
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // CircleAvatar(
                        //   radius: 50,
                        //   backgroundColor: Colors.blueAccent,
                        //   child: Text(
                        //     user.name.isNotEmpty
                        //         ? user.name[0].toUpperCase()
                        //         : '?',
                        //     style: const TextStyle(
                        //       fontSize: 40,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
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
              const SizedBox(height: 24),
              _buildProfileCard(title: 'Name', value: user.name),
              const SizedBox(height: 12),
              _buildProfileCard(title: 'Email', value: user.email),
              const SizedBox(height: 12),
              _buildProfileCard(title: 'Role', value: user.role),
              const SizedBox(height: 12),
              // _buildProfileCard(title: 'Department', value: user.departmentId),
              // const SizedBox(height: 12),
              SizedBox(height: 8),
              ElevatedButton(
              onPressed: _pickImage,
              child: Text('Edit Profile Image'),
            ),
            ],
          ),
        ),
      ),
   floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(),
            ),
          );
        },
        tooltip: 'Edit Profile',
        child: const Icon(Icons.edit),
      )
    

    );
  }

  Widget _buildProfileCard({required String title, required String value}) {
    return SizedBox(
      height: 80, // Fixed height for consistency
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text(
                '$title: ',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
