import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorViewSubmissionScreen extends StatelessWidget {
  final String doctorId;
  final String courseId;

  DoctorViewSubmissionScreen({required this.doctorId, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submissions'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('assignments')
            .where('courseId', isEqualTo: courseId)
            .where('createdBy', isEqualTo: doctorId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No assignments found.'));
          }

          final assignments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index].data() as Map<String, dynamic>;
              final assignmentId = assignments[index].id; // Use assignmentId to query submissions
              final assignmentTitle = assignment['title'] ?? 'Untitled Assignment';

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Assignment: $assignmentTitle'),
                  subtitle: Text('View Submissions'),
                  onTap: () {
                    _viewSubmissions(context, assignmentId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewSubmissions(BuildContext context, String assignmentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewSubmissionsScreen(assignmentId: assignmentId),
      ),
    );
  }
}

class ViewSubmissionsScreen extends StatefulWidget {
  final String assignmentId;

  ViewSubmissionsScreen({required this.assignmentId});

  @override
  _ViewSubmissionsScreenState createState() => _ViewSubmissionsScreenState();
}

class _ViewSubmissionsScreenState extends State<ViewSubmissionsScreen> {
  List<DocumentSnapshot> _submissions = [];
  bool _isSortedByEarly = true; // Track if sorting is by early submissions (ascending date)

  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return userSnapshot.data();
    } catch (e) {
      print('Failed to fetch user data: $e');
      return null;
    }
  }

  void _sortSubmissions() {
    setState(() {
      _submissions.sort((a, b) {
        final dataA = a.data() as Map<String, dynamic>;
        final dataB = b.data() as Map<String, dynamic>;
        
        // Fetch the submission timestamps (submittedAt)
        final timestampA = (dataA['submittedAt'] as Timestamp?)?.toDate();
        final timestampB = (dataB['submittedAt'] as Timestamp?)?.toDate();

        // Ensure both timestamps are valid
        if (timestampA != null && timestampB != null) {
          return _isSortedByEarly
              ? timestampA.compareTo(timestampB) // Early submissions first
              : timestampB.compareTo(timestampA); // Late submissions first
        }

        return 0; // If timestamps are not valid, return 0 (no change)
      });
      _isSortedByEarly = !_isSortedByEarly; // Toggle sorting order
    });
  }
    String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate = "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}";
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submissions for Assignment'),
        actions: [
          IconButton(
            icon: Icon(
              _isSortedByEarly ? Icons.arrow_upward : Icons.arrow_downward,
            ),
            onPressed: _sortSubmissions, // Toggle sorting based on submittedAt date
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('submissions')
            .where('assignmentId', isEqualTo: widget.assignmentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No submissions found.'));
          }

          final submissions = snapshot.data!.docs;

          // Store the submissions in the local list only once
          if (_submissions.isEmpty) {
            _submissions = List.from(submissions);
          }

          return ListView.builder(
            itemCount: _submissions.length,
            itemBuilder: (context, index) {
              final submission = _submissions[index].data() as Map<String, dynamic>;
              final userId = submission['userId'] ?? 'Unknown User';
                            
              final submittedAt = submission['submittedAt'] as Timestamp?;
              return FutureBuilder<Map<String, dynamic>?>( 
                future: _fetchUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Fetching user info...'),
                    );
                  }
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text('Unknown Student'),
                      subtitle: Text('No additional info available.'),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final studentName = userData['name'] ?? 'Unknown Student';
                  final studentEmail = userData['email'] ?? 'Unknown Email';

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Submission by: $studentName'),
                      subtitle: Text(
                        'Email: $studentEmail\n'
                        'Answer: ${submission['notes'] ?? 'No notes provided'}\n'
                        'Submitted at: ${submittedAt != null ? _formatDate(submittedAt) : 'Unknown time'}',
                     ) ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
