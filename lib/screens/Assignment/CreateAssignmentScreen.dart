import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/AssignmentService.dart'; 

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  _CreateAssignmentScreenState createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final AssignmentService _assignmentService = AssignmentService(); // Backend service instance

  String title = '';
  String description = '';
  DateTime? dueDate;

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create the assignment data
      Map<String, dynamic> assignmentData = {
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'courseId': 'sampleCourseId', // Replace with actual course ID
      };

      // Save to Firestore using the service
      try {
        await _assignmentService.createAssignment(assignmentData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment created successfully!')),
        );
        Navigator.pop(context); // Go back after creation
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => title = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    dueDate = selectedDate;
                  });
                },
                child: Text(dueDate == null ? 'Pick Due Date' : dueDate.toString()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Create Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
