// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class CoursesNotifier extends StateNotifier<List<Course>> {
//   final UserService _userService = UserService();
//   CoursesNotifier() : super(const []);

//   void viewUserCourses(String userId) {
//     _userService.fetchEnrolledCoursesByUserId(userId);
//   }
// }

// final coursesProvider = StateNotifierProvider((ref){
//   return CoursesNotifier();
// });


// final coursesProvider = StateNotifierProvider<CoursesNotifier, AsyncValue<List<Map<String, dynamic>>>>(
//   (ref) => CoursesNotifier(ref),
// );




import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/services/CourseService.dart';

final courseServiceProvider = Provider((ref) => CourseService());

// Courses provider with doctorId as a parameter
final coursesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, doctorId) {
  final courseService = ref.read(courseServiceProvider);
  return courseService.fetchEnrolledCoursesByUserId(doctorId);
});
