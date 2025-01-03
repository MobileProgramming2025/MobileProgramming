import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_courses_screen.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:uuid/uuid.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CourseService _courseService = CourseService();

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

  Future<void> enrollStudent() async {
    var enrolledCourses = 0;
    final users = await getAllUsers();
    final courses = await _courseService.getAllCourses();

    for (var user in users) {
      // isSucceeded(user);
          print('User: ${user.name}, Email: ${user.email}, Role: ${user.role}');


      if (user.role == 'student') {
        for (var course in courses) {
          if (user.year == course.year &&
              user.department == course.departmentName) {

            if (!_isEnrolled(course, user) && !_isTaken(course, user)) {
              _enroll(course, user);
              enrolledCourses++;
              print("enrolled");
            }
          }
          if (enrolledCourses >= 1) {
            break;
          }
        }
      }
    }
  }

  void _enroll(Course course, User user) async {
    final enrolledCoursesList = user.enrolledCourses;
    if (user.enrolledCourses.isEmpty) {
      print("Empty");
      enrolledCoursesList.add(course);
    }
    await updateUser(user);
  }

  bool _isEnrolled(Course course, User user) {
    for (var enrolled in user.enrolledCourses) {
      if (enrolled.code == course.code) {
        return true;
      }
    }
    return false;
  }

  bool _isTaken(Course course, User user) {
    for (var taken in user.takenCourses) {
      if (taken.code == course.code) {
        return true;
      }
    }
    return false;
  }

  // Future<bool> isSucceeded(User user)async{
  //   final now = DateTime.now();
  //   final currentYear = now.year;
  //   final studentAddedYear = user.addedDate.year;
  //   final educationYears = ((currentYear - studentAddedYear) + 1);
  //   var userYear = int.parse(user.year);
  //   if(educationYears > userYear){
  //    // userYear++;
  //    // await updateUser(user);
  //     return true;
  //   }
  //   return false;
  // }
}
