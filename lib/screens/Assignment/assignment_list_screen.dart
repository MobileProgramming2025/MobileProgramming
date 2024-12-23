import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_edit_assignment_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  final String courseId;

  const AssignmentListScreen({super.key, required this.courseId});

  @override
  _AssignmentListScreenState createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  void _fetchAssignments() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('assignments')
        .where('courseId', isEqualTo: widget.courseId)
        .get();
    setState(() {
      _assignments = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    });
  }

  void _deleteAssignment(String assignmentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('assignments')
          .doc(assignmentId)
          .delete();
      setState(() {
        _assignments.removeWhere((assignment) => assignment['id'] == assignmentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment deleted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete assignment: $error')),
      );
    }
  }

  void _confirmDelete(BuildContext context, String assignmentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Assignment'),
          content: Text('Are you sure you want to delete this assignment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteAssignment(assignmentId);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddEditAssignment({String? assignmentId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditAssignmentScreen(
          courseId: widget.courseId,
          assignmentId: assignmentId,
        ),
      ),
    ).then((_) => _fetchAssignments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      ),
      body: ListView.builder(
        itemCount: _assignments.length,
        itemBuilder: (context, index) {
          final assignment = _assignments[index];
          return GestureDetector(
            onTap: () {},
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment['title'],
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.teal[800]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    assignment['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Due: ${assignment['dueDateTime'].toDate()}',
                    style: TextStyle(color: Colors.amber[800]),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _navigateToAddEditAssignment(assignmentId: assignment['id']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, assignment['id']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditAssignment(),
        child: Icon(Icons.add),
      ),
    );
  }
}
