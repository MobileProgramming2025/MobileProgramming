import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditAssignmentScreen extends StatefulWidget {
  final String courseId;
  final String? assignmentId;
  final Future<void> Function() onAssignmentAdded;
  final Future<void> Function() onAssignmentUpdated;

  const AddEditAssignmentScreen({
    Key? key,
    required this.courseId,
    this.assignmentId,
    required this.onAssignmentAdded,
    required this.onAssignmentUpdated,
  }) : super(key: key);

  @override
  State<AddEditAssignmentScreen> createState() => _AddEditAssignmentScreenState();
}

class _AddEditAssignmentScreenState extends State<AddEditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;

  @override
  void initState() {
    super.initState();
    if (widget.assignmentId != null) {
      _loadAssignmentDetails();
    }
  }

  void _loadAssignmentDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('assignments')
        .doc(widget.assignmentId)
        .get();
    final data = doc.data()!;
    setState(() {
      _title = data['title'];
      _description = data['description'];
      _dueDate = (data['dueDateTime'] as Timestamp).toDate();
      _dueTime = TimeOfDay.fromDateTime(_dueDate!);
    });
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final dueDateTime = DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime!.hour,
      _dueTime!.minute,
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (widget.assignmentId == null) {
        // Create a new assignment
        await FirebaseFirestore.instance.collection('assignments').add({
          'courseId': widget.courseId,
          'title': _title,
          'description': _description,
          'dueDateTime': dueDateTime,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await widget.onAssignmentAdded(); // Trigger the callback
      } else {
        // Update an existing assignment
        await FirebaseFirestore.instance
            .collection('assignments')
            .doc(widget.assignmentId)
            .update({
          'title': _title,
          'description': _description,
          'dueDateTime': dueDateTime,
          'updatedBy': user.uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await widget.onAssignmentUpdated(); // Trigger the callback
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save assignment: $error')),
      );
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignmentId == null ? 'Add Assignment' : 'Edit Assignment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate == null
                          ? 'No date chosen!'
                          : 'Date: ${_dueDate!.toLocal()}'.split(' ')[0],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Choose Date'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueTime == null
                          ? 'No time chosen!'
                          : 'Time: ${_dueTime!.format(context)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: Text('Choose Time'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAssignment,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(widget.assignmentId == null ? 'Create Assignment' : 'Update Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
