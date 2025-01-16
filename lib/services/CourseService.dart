import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';

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

  Stream<List<Course>> getCoursesByDepartmentId(String departmentId) {
    try { 
      return _firestore
          .collection('Courses')
          .where('departmentId', isEqualTo: departmentId) 
          .snapshots() // Get real-time stream of query results
          .map((querySnapshot) {
        // Transform each QuerySnapshot into a List of Course objects
        return querySnapshot.docs.map((doc) {
          final data = doc.data(); // Extract Firestore document data
          return Course(
            id: data['id'],
            name: data['name'],
            departmentId: data['departmentId'],
            code: data['code'],
            year: data['year'],
          );
        }).toList(); // Convert the Iterable to a List
      });
    } catch (e) {
      throw Exception('Failed to retrieve Course');
    }
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

      final docRef = await _firestore.collection('Courses').add({
        // 'id': id,
        'name': name,
        'code': code,
        // 'drId': drId,
        // 'taId': taId,
        'departmentId': departmentId,
        'year': year,
      });
      // Update the document to set the 'id' field to match doc.id
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception("Failed to add Course: $e");
    }
  }



  void enrollInstructor(){

  }
}
