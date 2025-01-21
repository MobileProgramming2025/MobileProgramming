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

  Future<void> addCourse(Course newCourse) async {
    try {
      // Add the course to the backend
      await courseService.addCourse(
        id: newCourse.id,
        name: newCourse.name,
        code: newCourse.code,
        departmentId: newCourse.departmentId,
        year: newCourse.year,
      );

      // Update the state to reflect the newly added course
      state = [...state, newCourse];
    } catch (e) {
      print('Error adding course: $e');
      throw Exception('Failed to add course: $e');
    }
  }

  Future<void> removeUserCourse(String userId, String courseId) async {
    try {
      // Remove the course from the backend
      await courseService.removeCourseFromUser(userId, courseId);

      // Update the state to reflect the course removal
      state = state.where((course) => course.id != courseId).toList();
    } catch (e) {
      print('Error removing user course: $e');
      throw Exception('Failed to remove course: $e');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      // Remove the course from the backend
      await courseService.deleteCourse(courseId);

      // Update the state to reflect the course removal
      state = state.where((course) => course.id != courseId).toList();
    } catch (e) {
      print('Error removing user course: $e');
      throw Exception('Failed to remove course: $e');
    }
  }
}
