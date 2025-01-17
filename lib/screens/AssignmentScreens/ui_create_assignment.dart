import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileprogramming/design_course_app_theme.dart';

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

class _AddEditAssignmentScreenState extends State<AddEditAssignmentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _animationController?.forward();

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
        await FirebaseFirestore.instance.collection('assignments').add({
          'courseId': widget.courseId,
          'title': _title,
          'description': _description,
          'dueDateTime': dueDateTime,
          'createdBy': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        await widget.onAssignmentAdded();
      } else {
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
        await widget.onAssignmentUpdated();
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
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.asset('assets/design_course/webInterFace.png'),
                ),
              ],
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.2) - 24.0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: DesignCourseAppTheme.nearlyWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: DesignCourseAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: Text(widget.assignmentId == null
                                ? 'Create Assignment'
                                : 'Update Assignment'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
