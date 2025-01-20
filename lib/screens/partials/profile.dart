import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/UserBottomNavigationBar.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
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
  final DatabaseHelper dbHelper = DatabaseHelper();
  File? _profileImage;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    user = widget.user;
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
      // Handle the error or log it for debugging
      print('Error fetching user details: $error');
    }
  }

// Future<void> _saveProfileImagePath(String path) async {
//   final dbHelper = DatabaseHelper();
//   await dbHelper.updateProfileImagePath(user.id, path);
// }
//  Future<void> _loadUserData() async {
//     final loadedUser = await dbHelper.getUserById(user.id);
//     if (loadedUser != null) {
//       setState(() {
//         user = loadedUser;
//         if (user.profileImagePath != null) {
//           _profileImage = File(user.profileImagePath!);
//         }
//       });
//     }
//   }

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
        drawer: widget.user.role == 'Admin'
            ? AdminDrawer(user: widget.user)
            : UserDrawerScreen(user: widget.user),
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
                          //              _profileImagePath == null
                          // ? Text('No profile image selected.')
                          // : Image.file(File(_profileImagePath!)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: _pickImage, // Make the CircleAvatar tappable
                  child: Stack(
                    children: [
                      // Profile Image
                      _profileImagePath == null
                          ? CircleAvatar(
                              radius: 50,
                              child: Icon(Icons.account_circle, size: 50),
                            )
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  FileImage(File(_profileImagePath!)),
                            ),
                    ],
                  ),
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
        ),

      bottomNavigationBar: widget.user.role == 'Student'? UserBottomNavigationBar(user: widget.user): null,

        );
  }
}
