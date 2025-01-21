import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/models/Course.dart';

class CourseStateNotifier extends StateNotifier<List<Course>> {
  final CourseService courseService;

  CourseStateNotifier(this.courseService) : super([]);

  // Fetch courses and update the state
  Future<void> fetchUserCourses(String userId) async {
    try {
      // Wait for the asynchronous operation to complete
      final courses =
          await courseService.fetchEnrolledCoursesByUserId(userId).first;

      // Once the data is fetched, set the state to the new list of courses
      state = courses.map((courseData) {
        // Map the data to Course objects
        return Course.fromMap(courseData);
      }).toList();
    } catch (e) {
      state = [];
    }
  }

  // Fetch courses and update the state
  Future<void> fetchAllCourses() async {
    try {
      // Wait for the asynchronous operation to complete
      final courses = await courseService.getAllCourses().first;

      // Once the data is fetched, set the state to the new list of courses
      state = courses.map((courseData) {
        // Map the data to Course objects
        return Course.fromMap(courseData);
      }).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> fetchDepartmentCourses(String departmentId) async {
    try {
      // Wait for the asynchronous operation to complete
      final courses =
          await courseService.gettCoursesByDepartmentId(departmentId).first;

      // Once the data is fetched, set the state to the new list of courses
      state = courses.map((courseData) {
        // Ensure that courseData is a Map<String, dynamic> from Firestore
        return Course.fromMap(courseData);
      }).toList();
    } catch (e) {
      state = [];
    }
  }

  Future<void> removeUserCourse(String userId, String courseId) async {
    try {
      // Wait for the asynchronous operation to complete
      return courseService.removeCourseFromUser(userId, courseId);
    } catch (e) {
      throw Exception('Failed to remove course: $e');
    }
  }
}
