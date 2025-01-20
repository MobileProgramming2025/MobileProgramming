import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditAssignmentScreen extends StatefulWidget {
  final String courseId;
  final String? assignmentId;
  final Future<void> Function() onAssignmentAdded;
  final Future<void> Function() onAssignmentUpdated;

  const AddEditAssignmentScreen({
    super.key,
    required this.courseId,
    this.assignmentId,
    required this.onAssignmentAdded,
    required this.onAssignmentUpdated,
  });

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
    if (dueDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Due date and time cannot be in the past.')),
      );
      return;
    }
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }
      final duplicateCheck = await FirebaseFirestore.instance
          .collection('assignments')
          .where('title', isEqualTo: _title)
          .where('courseId', isEqualTo: widget.courseId)
          .get();

      if (duplicateCheck.docs.isNotEmpty && widget.assignmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An assignment with this title already exists.')),
        );
        return;
      }

      if (widget.assignmentId == null) {
        // Create a new assignment
        final assignmentRef = await FirebaseFirestore.instance.collection('assignments').add({
          'courseId': widget.courseId,
          'title': _title,
          'description': _description,
          'dueDateTime': dueDateTime,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Create notification
       await createNotificationsForCourse(widget.courseId, _title, 'A new assignment is added', user.uid);

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

        // Create notification for update
       await createNotificationsForCourse(widget.courseId, _title, 'A new assignment is updated', user.uid);

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

Future<void> createNotificationsForCourse(String courseId, String assignmentTitle, String message, String createdBy) async {
  final currentTime = Timestamp.now();
  final expiryTime = Timestamp.fromDate(DateTime.now().add(Duration(days: 7)));

  // Fetch the course document to get the course code
  final courseDoc = await FirebaseFirestore.instance.collection('Courses').doc(courseId).get();
  if (!courseDoc.exists) {
    print('Course not found for courseId: $courseId');
    return; // Exit if course doesn't exist
  }
  final courseCode = courseDoc.data()?['code']; // Get the course code from the document

  if (courseCode == null) {
    print('Course code is missing in the course document.');
    return;
  }

  // Fetch all users enrolled in the course
  final studentsSnapshot = await FirebaseFirestore.instance
    .collection('users')
    .where('role', isEqualTo: 'Student')
    .get();

final students = studentsSnapshot.docs.where((doc) {
  final enrolledCourses = doc.data()['enrolled_courses'] as List<dynamic>;
  return enrolledCourses.any((course) => course['code'] == courseCode);
}).toList();

print('Found ${students.length} students enrolled in course with code $courseCode.');

for (var student in students) {
  print('Creating notification for student ID: ${student.id}');
  await FirebaseFirestore.instance.collection('notifications').add({
    'userId': student.id,  // Student ID
    'title': assignmentTitle,
    'message': message,
    'createdBy': createdBy,  // Doctor ID or name
    'createdAt': currentTime,
    'expiresAt': expiryTime,
  });
  print('Notification created for student ID: ${student.id}');
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
