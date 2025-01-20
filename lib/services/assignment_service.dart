  import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> fetchAssignmentsByCourseId(String courseId) {
    return _firestore
        .collection('Assignments')
        .where('courseId', isEqualTo: courseId)  // Filter assignments by courseId
        .snapshots() // Real-time stream
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'title': doc['title'],
          'description': doc['description'],
          'courseId': doc['courseId'],
          'createdBy': doc['createdBy'],
        };
      }).toList();
    });
  }}