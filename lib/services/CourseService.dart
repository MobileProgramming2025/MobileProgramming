import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<List<Course>> getAllCourses() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('Courses').get();
    return querySnapshot.docs
        .map((doc) => Course.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // add course to Firestore
  Future<void> addCourse({
    required String id,
    required String name,
    required String code,
    required String drName,
    required String taName,
    required String departmentName,
    required String year,
  }) async {
    try {
      await _firestore.collection('Courses').add({
        'id': id,
        'name': name,
        'code': code,
        'drName': drName,
        'taName': taName,
        'departmentName': departmentName,
        'year': year,
      });
    } catch (e) {
      throw Exception("Failed to add Course: $e");
    }
  }
}
