import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  String? _selectedCourse;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Assignment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              hint: const Text('Select Course'),
              items: ['Course1', 'Course2', 'Course3'] // Replace with dynamic courses
                  .map((course) => DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _dueDateController,
              decoration: const InputDecoration(labelText: 'Due Date (yyyy-MM-dd)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createAssignment,
              child: const Text('Create Assignment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createAssignment() async {
    if (_selectedCourse == null ||
        _titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _dueDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    try {
      final createdBy = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final assignment = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': _dueDateController.text,
        'courseId': _selectedCourse,
        'createdBy': createdBy,
      };

      await _firestore.collection('Assignments').add(assignment);
      
      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment created successfully!')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
