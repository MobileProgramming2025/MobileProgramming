import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/user_service.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class EnrollStudentsScreen extends StatefulWidget {
  const EnrollStudentsScreen({super.key});

  @override
  State<EnrollStudentsScreen> createState() {
    return _EnrollStudentsScreenState();
  }
}

class _EnrollStudentsScreenState extends State<EnrollStudentsScreen> {
  final UserService _userService = UserService();

  void _enroll() async {
    try {
      _userService.enrollStudent();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Students are enrolled Sucessfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll students: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enroll Students to Courses",
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: _enroll,
                      child: Text(
                        'Enroll Students To Courses',
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
