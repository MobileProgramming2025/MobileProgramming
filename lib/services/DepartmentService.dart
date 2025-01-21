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
          // print('Department with ID $id not found in Firestore.');
          return null;
        }
      });
    } catch (e) {
      // print('Error retrieving user with ID $id: $e');
      throw Exception('Failed to retrieve user');
    }
  }

  // Checks if a user with the given uid exists in Firestore
  Future<bool> checkIfDepartmentExists(String id) async {
    try {
      DocumentSnapshot depDoc =
          await _firestore.collection('Departments').doc(id).get();
      return depDoc.exists;
    } catch (e) {
      // print("Error checking if user exists: $e");
      return false;
    }
  }

  Future<void> addDepartment({
    required String id,
    required String name,
    required String capacity,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('Departments')
          .where('name', isEqualTo: name)
          .get();
      // If a department with the same name is found, do not add it
      if (querySnapshot.docs.isNotEmpty) {
        throw Exception("Department with name '$name' already exists.");
      }

      final docRef = await _firestore.collection('Departments').add({
        'name': name,
        'capacity': capacity,
      });
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception("Failed to add Department: $e");
    }
  }

  Future<void> editDepartment({
    required String id,
    required String name,
    required String capacity,
  }) async {
    try {
      final docRef = _firestore.collection('Departments').doc(id);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception("Department with ID '$id' does not exist.");
      }

      final querySnapshot = await _firestore
          .collection('Departments')
          .where('name', isEqualTo: name)
          .get();

      if (querySnapshot.docs.any((doc) => doc.id != id)) {
        throw Exception(
            "Another department with the name '$name' already exists.");
      }

      await docRef.update({
        'name': name,
        'capacity': capacity,
      });
    } catch (e) {
      throw Exception("Failed to edit Department: $e");
    }
  }
}
