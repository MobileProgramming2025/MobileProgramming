import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Course {
  final String id;
  final String name;
  final String code;
  final String drName;
  final String taName;
  final String departmentName;
  final String year;

  Course(
      {required this.id,
      required this.name,
      required this.code,
      required this.drName,
      required this.taName,
      required this.year,
      required this.departmentName});
      
  // Convert a Course object to a Map for Firestore
  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'drName': drName,
      'taName': taName,
      'departmentName': departmentName,
      'year': year,
    };
  }

  // Save course to Firestore
  // Future<void> saveToFirestore() async {
  //   final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   await firestore.collection('Courses').doc(id).set(toMap());
  // }
}
