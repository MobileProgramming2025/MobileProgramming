import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_assignment_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  final String courseId;

  const AssignmentListScreen({
    super.key,
    required this.courseId,
  });

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _assignments = [];
  Map<String, dynamic>? _deletedAssignment;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  void _fetchAssignments() async {
    if (_currentUser == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .where('courseId', isEqualTo: widget.courseId)
          .where('createdBy', isEqualTo: _currentUser!.uid)
          .get();

      setState(() {
        _assignments = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch assignments: $e')),
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

  void _deleteAssignment(String assignmentId) async {
    try {
      final assignmentToDelete = _assignments.firstWhere((assignment) => assignment['id'] == assignmentId);

      // Temporarily save the deleted assignment
      setState(() {
        _deletedAssignment = assignmentToDelete;
        _assignments.removeWhere((assignment) => assignment['id'] == assignmentId);
      });

      // Show snackbar with undo button
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Assignment deleted successfully!'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _undoDelete();
            },
          ),
        ),
      );

      await FirebaseFirestore.instance.collection('assignments').doc(assignmentId).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete assignment: $e')),
      );
    }
  }

  void _undoDelete() async {
    if (_deletedAssignment == null) return;

    try {
      // Restore the deleted assignment to Firestore
      await FirebaseFirestore.instance.collection('assignments').add({
        'courseId': _deletedAssignment!['courseId'],
        'title': _deletedAssignment!['title'],
        'description': _deletedAssignment!['description'],
        'dueDateTime': _deletedAssignment!['dueDateTime'],
        'createdBy': _currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _assignments.add(_deletedAssignment!);
        _deletedAssignment = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assignment restored successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to restore assignment: $e')),
      );
    }
  }

  void _navigateToAddEditAssignment({String? assignmentId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddEditAssignmentScreen(
              courseId: widget.courseId,
              assignmentId: assignmentId,
              onAssignmentAdded: _onAssignmentAdded,
              onAssignmentUpdated: _onAssignmentUpdated,
            ),
          ),
        )
        .then((_) => _fetchAssignments());
  }

  Future<void> _onAssignmentAdded() async {
    _fetchAssignments();
  }

  Future<void> _onAssignmentUpdated() async {
    _fetchAssignments();
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
                color: Color.fromARGB(255, 228, 151, 78),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
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
                  ),
                  SizedBox(height: 8),
                  Text(
                    assignment['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Due: ${assignment['dueDateTime'].toDate()}',
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
