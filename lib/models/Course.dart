
import 'package:uuid/uuid.dart';

final uuid = Uuid();
class Course {
  final String id;
  final String name;
  final String code;
  final String drName;
  final String taName;
  final int year;

  Course({required this.name, required this.code, required this.drName, required this.taName, required this.year}): id = uuid.v4();
  

}
