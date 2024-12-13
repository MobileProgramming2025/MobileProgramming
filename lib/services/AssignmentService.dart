import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
  final CollectionReference assignments = FirebaseFirestore.instance.collection('assignments');

  Future<void> createAssignment(Map<String, dynamic> data) async {
    await assignments.add(data);
  }

  Future<List<Map<String, dynamic>>> fetchAssignments(String courseId) async {
    QuerySnapshot query = await assignments.where('courseId', isEqualTo: courseId).get();
    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> updateAssignment(String assignmentId, Map<String, dynamic> data) async {
    await assignments.doc(assignmentId).update(data);
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await assignments.doc(assignmentId).delete();
  }
}
