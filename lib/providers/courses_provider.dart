import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/providers/course_state_notifier.dart';
import 'package:mobileprogramming/services/CourseService.dart';

final courseServiceProvider = Provider((ref) => CourseService());


final courseStateProvider =  StateNotifierProvider<CourseStateNotifier, List<Course>>(
  (ref) => CourseStateNotifier(ref.read(courseServiceProvider)),
);
 

final departmentCoursesStateProvider =  StateNotifierProvider<CourseStateNotifier, List<Course>>(
  (ref) => CourseStateNotifier(ref.read(courseServiceProvider)),
);
