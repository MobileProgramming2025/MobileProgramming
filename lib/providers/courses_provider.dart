
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/Course.dart';

class CoursesNotifier extends StateNotifier<List<Course>>{
  CoursesNotifier():super(const []);

}

final coursesProvider = Provider((ref){
  // return new Course();
});
