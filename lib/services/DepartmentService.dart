import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Department.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAllDepartments() {
    return FirebaseFirestore.instance
        .collection('Departments')
        .snapshots()
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

  Stream<Department?> getDepartmentByID(String id) {
    try {
      return _firestore
          .collection('Departments')
          .doc(id)
          .snapshots()
          .map((docSnapshot) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return Department.fromMap(docSnapshot.data()!);
        } else {
          print('Department with ID $id not found in Firestore.');
          return null;
        }
      });
    } catch (e) {
      print('Error retrieving user with ID $id: $e');
      throw Exception('Failed to retrieve user');
    }
  }

  // add course to Firestore
  Future<void> addDepartment({
    required String id,
    required String name,
    required String capacity,
  }) async {
    try {
      await _firestore.collection('Departments').add({
        'id': id,
        'name': name,
        'capacity': capacity,
      });
    } catch (e) {
      throw Exception("Failed to add Course: $e");
    }
  }
}
