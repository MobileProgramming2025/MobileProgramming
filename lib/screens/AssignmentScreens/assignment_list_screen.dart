import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/doctor-view-submission-screen.dart';
import 'add_edit_assignment_screen.dart';
// import 'package:mobileprogramming/models/user.dart' as AppUser;

class AssignmentListScreen extends StatefulWidget {
  final String courseId;
  // final Doctor doctor;

  const AssignmentListScreen({
    super.key, required this.courseId ,
    // required this.doctor
    });

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser; // Current logged-in user
  List<Map<String, dynamic>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }
  

  void _fetchAssignments() async {
  if (_currentUser == null) return; // Ensure user is logged in
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('assignments')
        .where('courseId', isEqualTo: widget.courseId) // Filter by courseId
        .where('createdBy', isEqualTo: _currentUser.uid)
        .get();

    setState(() {
      _assignments = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  } catch (e) {
    if(!mounted) return;
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
          title: Text('Delete Assignment', style: TextStyle(color: const Color.fromARGB(255, 10, 1, 0))),
          content: Text('Are you sure you want to delete this assignment?' , style: TextStyle(color: Colors.grey[700])),
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
  // Find the assignment details before deleting
  final assignmentToDelete = _assignments.firstWhere((assignment) => assignment['id'] == assignmentId);

  try {
    // Temporarily remove the assignment from the list
    setState(() {
      _assignments.removeWhere((assignment) => assignment['id'] == assignmentId);
    });

    // Show SnackBar with Undo option
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Assignment deleted'),
        duration: Duration(seconds: 7),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Re-add the assignment back to the list
            setState(() {
              _assignments.add(assignmentToDelete);
            });
            scaffoldMessenger.hideCurrentSnackBar(); // Hide the SnackBar immediately if Undo is pressed
          },
        ),
      ),
    );

    // Wait for the SnackBar duration before permanently deleting the assignment
    await Future.delayed(Duration(seconds: 7));

    // Check if the assignment was re-added (Undo pressed)
    if (!_assignments.any((assignment) => assignment['id'] == assignmentId)) {
      await FirebaseFirestore.instance.collection('assignments').doc(assignmentId).delete();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Assignment permanently deleted')),
      );
    }
  } catch (e) {
    // If an error occurs or the undo was pressed after deletion started, re-add the assignment
    setState(() {
      if (!_assignments.any((assignment) => assignment['id'] == assignmentId)) {
        _assignments.add(assignmentToDelete);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to delete assignment: $e')),
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
  // Handle logic when an assignment is added
  // print('Assignment added!');
  _fetchAssignments();
}

Future<void> _onAssignmentUpdated() async {
  // Handle logic when an assignment is updated
  // print('Assignment updated!');
   _fetchAssignments();
}
 void _viewSubmissions(String assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewSubmissionsScreen(assignmentId: assignmentId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignments'),
      //  leading: Builder(
      //     builder: (context) => IconButton(
      //       icon: Icon(Icons.menu),
      //       onPressed: () => Scaffold.of(context).openDrawer(),
      //     ),
      //   ),
      ),
   //  drawer: DoctorDrawer(user: widget.doctor),
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
                color: Color.fromARGB(255, 253, 241, 225),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                   // color: Color.fromARGB(255, 228, 151, 78)
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
                    //style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.teal[800]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    assignment['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Due: ${assignment['dueDateTime'].toDate()}',
                   // style: TextStyle(color: Colors.amber[800]),
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
                       IconButton(
                        icon: Icon(Icons.view_agenda, color: Colors.blue),
                        onPressed: () =>  _viewSubmissions(assignment['id']),
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