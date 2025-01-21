import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/providers/course_state_notifier.dart';
import 'package:mobileprogramming/services/CourseService.dart';

final courseServiceProvider = Provider((ref) => CourseService());

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


// StateNotifierProvider for managing the course state
final userCourseStateProvider =  StateNotifierProvider<CourseStateNotifier, List<Course>>(
  (ref) => CourseStateNotifier(ref.read(courseServiceProvider)),
);
