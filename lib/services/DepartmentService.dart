import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final UserService _userService = UserService();

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
