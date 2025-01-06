import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final UserService _userService = UserService();

  Stream<List<Map<String, dynamic>>> getAllCourses() {
    return FirebaseFirestore.instance.collection('Courses').snapshots().map(
        (snapshot){
      return snapshot.docs.map((doc) {
        // Extract the document's ID and fields, and create a usable map
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }




  // Future<List<Map<String, dynamic>>> getCourses() async {
  //   try {
  //     QuerySnapshot snapshot = await _firestore.collection('Courses').get();
  //     return snapshot.docs
  //         .map((doc) => {
  //               'id': doc.id,
  //               'name': doc['name'],
  //               'code': doc['code'],
  //               'drId': doc['drId'],
  //               'taId': doc['taId'],
  //               'departmentName': doc['departmentName'],
  //               'year': doc['year'],
  //             })
  //         .toList();
  //   } catch (e) {
  //     print('Error fetching courses: $e');
  //     return [];
  //   }
  // }

  // add course to Firestore
  Future<void> addCourse({
    required String id,
    required String name,
    required String code,
    required String drId,
    required String taId,
    required String departmentName,
    required String year,
  }) async {
    try {
      await _firestore.collection('Courses').add({
        'id': id,
        'name': name,
        'code': code,
        'drId': drId,
        'taId': taId,
        'departmentName': departmentName,
        'year': year,
      });
    } catch (e) {
      throw Exception("Failed to add Course: $e");
    }
  }

  // Future<void> deleteCourse(String id) async {
  //   try {
  //     // Delete subcollections first (if any)
  //     print("here ${id}");

  //     deleteAllCoursesFromUser(id);

  //     // Delete the parent document
  //     await _firestore.collection('Courses').doc(id).delete();
  //   } catch (e) {
  //     print("Failed to delete Course: $e");
  //     throw Exception("Failed to delete Course: $e");
  //   }
  // }

  // Future<void> deleteCourseFromUser(String userId, String courseId) async {
  //   try {
  //     print("courseId ${courseId}");
  //     await _firestore
  //         .collection('users')
  //         .doc(userId)
  //         .collection("enrolledCourses")
  //         .doc(courseId)
  //         .delete();
  //   } catch (e) {
  //     print("Failed to delete course: $e");
  //     throw Exception("Failed to delete course");
  //   }
  // }

  // Future<void> deleteAllCoursesFromUser(String courseId) async {
  //   final users = await _userService.getAllUsers();
  //   for (var user in users) {
  //     for (var course in user.enrolledCourses) {
  //       if (course.id == courseId) {
  //         deleteCourseFromUser(user.id, courseId);
  //       }
  //     }
  //   }
  // }
}
