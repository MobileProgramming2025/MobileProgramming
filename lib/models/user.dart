import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final List<Course> enrolledCourses;
  final List<Course> takenCourses;
  final DateTime addedDate;
  final String year;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.enrolledCourses,
    required this.takenCourses,
    required this.addedDate,
    required this.year,
  });

  // Convert a User object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'enrolled_courses': enrolledCourses,
      'taken_courses': takenCourses,
      'added_date': addedDate,
      'year': year,
    };
  }

  // Create a User object from Firestore Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '', // provide default value if null
      name: (map['name'] as String?) ??
          map['email'].split('@')[0], // Default to email before '@'
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'Unknown',
      department: map['department'] as String? ?? 'Unknown',
      enrolledCourses: map['enrolledCourses'] ?? [],
      takenCourses: map['takenCourses'] ?? [],
      addedDate:DateTime.utc(map['added_date']),
      year: map['year'] as String? ?? '',
    );
  }

  // Save user to Firestore
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(id).set(toMap());
  }

  // Retrieve all users from Firestore
  static Future<List<User>> getAllUsers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot querySnapshot =
        await firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Retrieve a user by ID from Firestore
  static Future<User?> getUserDetails(String id) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await firestore.collection('users').doc(id).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return User.fromMap(docSnapshot.data()!);
      } else {
        print('User with ID $id not found in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error retrieving user with ID $id: $e');
      return null;
    }
  }
}
