import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_courses_screen.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user to firestore
  Future<void> saveUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Failed to save user');
    }
  }

  // Retrieve all users from Firestore
  Future<List<User>> getAllUsers() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('users').get();
      final users = querySnapshot.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return users;
    } catch (e) {
      print('Error retrieving all users: $e');
      throw Exception('Failed to retrieve users');
    }
  }

  // Retrieve a user by ID from Firestore
  Future<User?> getUserByID(String id) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot =
          await _firestore.collection('users').doc(id).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return User.fromMap(docSnapshot.data()!);
      } else {
        print('User with ID $id not found in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error retrieving user with ID $id: $e');
      throw Exception('Failed to retrieve user');
    }
  }

  // Update user in Firestore
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  // Delete user by ID from Firestore
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user');
    }
  }

  final CourseService _courseService = CourseService();
  Future<void> enrollStudent() async {
    var enrolled_courses = 0;
    final users = await getAllUsers();
    final courses = await _courseService.getAllCourses();
    var isEnrolled = false;

    for (var user in users) {
      if (user.role == 'user') {
        for (var course in courses) {
          if (user.year == course.year) {
            _enroll(course,user);
            isEnrolled = true;
            print('User: ${user.name} ${user.year}can enroll in course: ${course.name}${course.year}');
          }

          if (enrolled_courses >= 5) {
            break;
          }
        }
      }
    }
  }

  void _enroll(Course course, User user) async{
    user.enrolledCourses.add(course);
    await updateUser(user);
    for(var e in user.enrolledCourses){
      print(e.name);
      print(e.code);

    }
  //   _courseService.addCourse(
  //       id: course.id,
  //       name: course.name,
  //       code: course.code,
  //       drName: course.drName,
  //       taName: course.taName,
  //       departmentName: course.departmentName,
  //       year: course.year);
  }
  bool _isEnrolled(){

    return false;
  }
}
