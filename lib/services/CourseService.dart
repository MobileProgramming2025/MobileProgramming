import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch courses
  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('courses').get();
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc['name'],
      }).toList();
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  // Add a new course
  Future<void> addCourse(String courseName) async {
    try {
      await _firestore.collection('courses').add({
        'name': courseName,  // Add more fields if necessary
      });
      print('Course added successfully');
    } catch (e) {
      print('Error adding course: $e');
    }
  }
}
