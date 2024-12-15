import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditAssignmentScreen extends StatefulWidget {
  final String courseId;
  final String? assignmentId;
  final DocumentSnapshot? assignmentData;

  AddEditAssignmentScreen({
    required this.courseId,
    this.assignmentId,
    this.assignmentData,
  });

  @override
  _AddEditAssignmentScreenState createState() =>
      _AddEditAssignmentScreenState();
}

class _AddEditAssignmentScreenState extends State<AddEditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
DateTime? _dueDate;
TimeOfDay? _dueTime;


  @override
  void initState() {
    super.initState();
    if (widget.assignmentData != null) {
      _title = widget.assignmentData!['title'];
      _description = widget.assignmentData!['description'];
      _dueDate = widget.assignmentData!['dueDateTime'].toDate();
    }
  }

  Future<void> _saveAssignment() async {
    if (_formKey.currentState?.validate() ?? false) {
  _formKey.currentState?.save();

  // Combine dueDate and dueTime
  final completeDueDateTime = DateTime(
    _dueDate!.year,
    _dueDate!.month,
    _dueDate!.day,
    _dueTime?.hour ?? 0,
    _dueTime?.minute ?? 0,
  );

  final assignmentData = {
    'title': _title,
    'description': _description,
    'dueDateTime': Timestamp.fromDate(completeDueDateTime),
    'createdBy': 'Doctor/TA Name',
    'courseId': widget.courseId, // Include actual courseId
  };

  if (widget.assignmentId == null) {
    await FirebaseFirestore.instance
        .collection('assignments')
        .doc(widget.courseId)
        .collection('assignments')
        .add(assignmentData);
  } else {
    await FirebaseFirestore.instance
        .collection('assignments')
        .doc(widget.courseId)
        .collection('assignments')
        .doc(widget.assignmentId)
        .update(assignmentData);
  }

  Navigator.pop(context);
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignmentId == null ? 'Add Assignment' : 'Edit Assignment'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
  children: [
    TextFormField(
      initialValue: _title,
      decoration: InputDecoration(labelText: 'Title'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Title is required' : null,
      onSaved: (value) => _title = value,
    ),
    TextFormField(
      initialValue: _description,
      decoration: InputDecoration(labelText: 'Description'),
      validator: (value) =>
          value == null || value.isEmpty ? 'Description is required' : null,
      onSaved: (value) => _description = value,
    ),
    ElevatedButton(
      onPressed: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: _dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (selectedDate != null) {
          setState(() {
            _dueDate = selectedDate;
          });
        }
      },
      child: Text(
        _dueDate != null
            ? 'Due Date: ${_dueDate!.toLocal()}'.split(' ')[0]
            : 'Select Due Date',
      ),
    ),
    ElevatedButton(
      onPressed: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: _dueTime ?? TimeOfDay.now(),
        );

        if (selectedTime != null) {
          setState(() {
            _dueTime = selectedTime;
          });
        }
      },
      child: Text(
        _dueTime != null
            ? 'Due Time: ${_dueTime!.format(context)}'
            : 'Select Due Time',
      ),
    ),
    ElevatedButton(
      onPressed: _saveAssignment,
      child: Text('Save Assignment'),
    ),
  ],
),
        ),
      ),
    );
  }
}
