import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final UserService _userService = UserService();

  Stream<List<Map<String, dynamic>>> getAllCourses() {
    return FirebaseFirestore.instance
        .collection('Courses')
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
  Future<void> addCourse({
    required String id,
    required String name,
    required String code,
    // required String drId,
    // required String taId,
    required String departmentId,
    required String year,
  }) async {
    try {
      final nameQuerySnapshot = await _firestore
          .collection('Courses')
          .where('name', isEqualTo: name)
          .get();
      if (nameQuerySnapshot.docs.isNotEmpty) {
        throw Exception("Course with name '$name' already exists.");
      }

      final codeQuerySnapshot = await _firestore
          .collection('Courses')
          .where('code', isEqualTo: code)
          .get();
      if (codeQuerySnapshot.docs.isNotEmpty) {
        throw Exception("Course Code '$code' already exists.");
      }

      await _firestore.collection('Courses').add({
        'id': id,
        'name': name,
        'code': code,
        // 'drId': drId,
        // 'taId': taId,
        'departmentId': departmentId,
        'year': year,
      });
    } catch (e) {
      throw Exception("Failed to add Course: $e");
    }
  }
}
