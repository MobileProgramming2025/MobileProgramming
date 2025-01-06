import 'package:mobileprogramming/models/Course.dart';

class Department {
  final String id;
  final String name;
  final String capacity;
  final List<Course> courses;

  Department({
    required this.id,
    required this.name,
    required this.capacity,
    required this.courses,
  });

  // Convert a Course object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'courses': courses.map((course) => course.toMap()).toList(),
    };
  }

  // Convert Firestore data to a course object
  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? '',
      courses: (map['courses'] as List<dynamic>? ?? [])
          .map((e) => Course.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
