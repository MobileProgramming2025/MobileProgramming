import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
  final _assignmentsCollection = FirebaseFirestore.instance.collection('Assignments');

  Future<void> createAssignment(String courseId, String title, String description, DateTime dueDate, String createdBy) async {
    try {
      await _assignmentsCollection.add({
        'courseId': courseId,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'createdBy': createdBy,
      });
      print("Assignment created successfully!");
    } catch (e) {
      print("Error creating assignment: $e");
    }
  }

  Stream<QuerySnapshot> getAssignmentsByCourse(String courseId) {
    return _assignmentsCollection.where('courseId', isEqualTo: courseId).snapshots();
  }
   Future<List<Map<String, dynamic>>> fetchAssignments(String courseId) async {
    final assignments = await FirebaseFirestore.instance
        .collection('Assignments')
        .where('courseId', isEqualTo: courseId)
        .get();
    return assignments.docs.map((doc) => doc.data()).toList();
  }
}
