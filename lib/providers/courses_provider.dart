import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/services/CourseService.dart';

final courseServiceProvider = Provider((ref) => CourseService());

// Courses provider 
// This allows us to instantiate and reuse the same instance of CourseService wherever needed
// .family -> pass an argument 
final userCoursesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final courseService = ref.read(courseServiceProvider);
  return courseService.fetchEnrolledCoursesByUserId(userId);
});

// StreamProvider for fetching all courses
final allCoursesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  // Accessing the CourseService instance
  final courseService = ref.read(courseServiceProvider);
  return courseService.getAllCourses();
});

final departmentCoursesProvider = StreamProvider.family<List<Course>, String>((ref, departmentId) {
  final courseService = ref.read(courseServiceProvider);
  return courseService.getCoursesByDepartmentId(departmentId);
});