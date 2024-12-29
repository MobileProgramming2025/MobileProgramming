import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // // Fetch courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
              })
          .toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }



  // add course to Firestore
  Future<void> addCourse({
    required String name,
    required String code,
    required String drName,
    required String taName,
    required String departmentName,
    required String year,
  }) async {
    try {
      await _firestore.collection('Courses').add({
        'name': name,
        'code': code,
        'drName': drName,
        'taName': taName,
        'departmentName': departmentName,
        'year': year,
      });
    } catch (e) {
      throw Exception("Failed to add doctor: $e");
    }
  }
}
