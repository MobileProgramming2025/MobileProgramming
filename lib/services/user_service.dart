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

  Stream<List<Map<String, dynamic>>> fetchAllUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Extract the document's ID and fields, and create a usable map
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // Retrieve a user by ID from Firestore
  Stream<User?> getUserByID(String id) {
    try {
      return _firestore
          .collection('users')
          .doc(id)
          .snapshots()
          .map((docSnapshot) {
        if (docSnapshot.exists && docSnapshot.data() != null) {
          return User.fromMap(docSnapshot.data()!);
        } else {
          print('User with ID $id not found in Firestore.');
          return null;
        }
      });
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
    final users = await fetchAllUsers().first;
    final courses = await _courseService.getAllCourses().first;
    for (var user in users) {
      // isSucceeded(user);
      if (user['role'] == 'Student') {
        print('\x1B[37m ${user['role']}');

        for (var course in courses) {
          if (user['year'] == course['year'] &&
              user['departmentId'] == course['departmentId']) {
            print(
                '\x1B[35m User: ${user['name']}, Email: ${user['email']}, Role: ${user['role']},year: ${user['year']}, dep: ${user['departmentId']} \x1B[0m');
            print('\x1B[35m ${course}\x1B[0m');

            if (!_isEnrolled(course, user) && !_isTaken(course, user)) {
              _enroll(course, user);
              enrolledCourses++;
              print("'\x1B[32m Enrolled \x1B[0m");
            }
          }
          if (enrolledCourses >= 1) {
            break;
          }
        }
      }
    }
  }

  void _enroll(Map<String, dynamic> course, Map<String, dynamic> user) async {
    user['enrolledCourses'] ??= [];
    user['enrolledCourses'].add(course);

    await _firestore.collection('users').doc(user['id']).update(user);
  }

  bool _isEnrolled(Map<String, dynamic> course, Map<String, dynamic> user) {
    final enrolledCourses = user['enrolledCourses'] ?? [];
    for (var enrolled in enrolledCourses) {
      if (enrolled['code'] == course['code']) {
        return true;
      }
    }
    return false;
  }

  bool _isTaken(Map<String, dynamic> course, Map<String, dynamic> user) {
    final takenCourses = user['takenCourses'] ?? [];
    for (var taken in takenCourses) {
      if (taken['code'] == course['code']) {
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
