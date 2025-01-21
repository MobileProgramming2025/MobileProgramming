import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/providers/course_state_notifier.dart';
import 'package:mobileprogramming/services/CourseService.dart';

final courseServiceProvider = Provider((ref) => CourseService());


// StateNotifierProvider for managing the course state
final userCourseStateProvider =  StateNotifierProvider<CourseStateNotifier, List<Course>>(
  (ref) => CourseStateNotifier(ref.read(courseServiceProvider)),
);
 
 final allCourseStateProvider =  StateNotifierProvider<CourseStateNotifier, List<Course>>(
  (ref) => CourseStateNotifier(ref.read(courseServiceProvider)),
);

final departmentCoursesProvider =  StateNotifierProvider<CourseStateNotifier, List<Course>>(
  (ref) => CourseStateNotifier(ref.read(courseServiceProvider)),
);