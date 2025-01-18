import 'package:cloud_firestore/cloud_firestore.dart';

class TaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAllTa() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: "Teaching Assistant")
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getTaByDepartmentId(String departmentId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: "Teaching Assistant")
        .where('departmentId', isEqualTo: departmentId)
        .snapshots() // Get real-time stream of query results
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Extract the document's ID and fields, and create a usable map
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }
}
