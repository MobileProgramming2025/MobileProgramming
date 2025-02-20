import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';
import 'package:uuid/uuid.dart';

class AddUserScreen extends StatefulWidget {
  final User admin;
  const AddUserScreen({super.key, required this.admin});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DepartmentService _departmentService = DepartmentService();

  final Uuid _uuid = Uuid();

  String? _selectedRole;
  String? _selectedDepartment;

  final List<String> _roles = [
    'Student',
    'Doctor',
    'Teaching Assistant',
    'Admin'
  ];

  bool _validName = true;
  bool _validEmail = true;
  bool _validPassword = true;
  bool _validRole = true;
  bool _validDepartment = true;

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _selectedRole = null;
      _selectedDepartment = null;
    });
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _validName = _nameController.text.trim().isNotEmpty;
      _validEmail = RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+$")
          .hasMatch(_emailController.text.trim());
      _validPassword = _passwordController.text.trim().length >= 8;
      _validRole = _selectedRole != null;
      _validDepartment =
          (_selectedRole == "Admin") || _selectedDepartment != null;

      isValid = _validName &&
          _validEmail &&
          _validPassword &&
          _validRole &&
          _validDepartment;
    });
    return isValid;
  }

  Future<void> _addUser() async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields correctly!'),
        ),
      );
      return;
    }

    String userId = _uuid.v4();

    try {
      // Create user in Firebase Authentication
      firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the Firebase UID
      String firebaseUid = userCredential.user!.uid;

      // Define the user object based on the selected role
      late User newUser;

      if (_selectedRole == "Student") {
        final firstAdded = DateTime.utc(2023, DateTime.november, 9);
        final currentYear = DateTime.now();
        final educationYear = currentYear.year - firstAdded.year;

        newUser = User(
          // id: userId,
          id: firebaseUid, // Use Firebase UID as the user ID
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole ?? 'Unknown',
          departmentId: _selectedDepartment ?? 'Unknown',
          takenCourses: [],
          enrolledCourses: [],
          addedDate: firstAdded,
          year: (educationYear + 1).toString(),
        );
      } else if (_selectedRole == "Teaching Assistant" ||
          _selectedRole == "Doctor") {
        newUser = User(
          id: firebaseUid, // Use Firebase UID as the user ID
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole ?? 'Unknown',
          departmentId: _selectedDepartment ?? 'Unknown',
          enrolledCourses: [],
        );
      } else if (_selectedRole == "Admin") {
        newUser = User(
          id: firebaseUid, // Use Firebase UID as the user ID
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole ?? 'Unknown',
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid role selected!')),
        );
        return;
      }

      // Save user details to Firestore
      await newUser.saveToFirestore();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added successfully!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a user'),
      ),
      drawer: AdminDrawer(user: widget.admin),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please, enter your password.";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters.";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                        // Clear the department selection if role change to "Admin"
                        if (_selectedRole == "Admin") {
                          _selectedDepartment = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Show department dropdown only f the selected role is not Admin
                  if (_selectedRole != "Admin")
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _departmentService.getAllDepartments(),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> depitems = [];
                        if (!snapshot.hasData) {
                          const CircularProgressIndicator();
                        } else {
                          final items = snapshot.data!;
                          for (var item in items) {
                            depitems.add(
                              DropdownMenuItem(
                                value: item['id'],
                                child: Text(
                                  item['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                        }
                        return DropdownButtonFormField(
                            validator: (value) {
                              if (value == null) {
                                return "please select a Department";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Department Name',
                              border: OutlineInputBorder(),
                            ),
                            items: depitems,
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartment = value!;
                              });
                            });
                      },
                    ),
                  SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: _addUser,
                      child: Text(
                        'Add User',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
