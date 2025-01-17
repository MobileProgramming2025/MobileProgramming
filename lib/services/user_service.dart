import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/services/CourseService.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CourseService _courseService = CourseService();

  // Save user to firestore
  Future<void> saveUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      // print('Error saving user: $e');
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
      // print('Error retrieving all users: $e');
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
          // print('User with ID $id not found in Firestore.');
          return null;
        }
      });
    } catch (e) {
      // print('Error retrieving user with ID $id: $e');
      throw Exception('Failed to retrieve user');
    }
  }

  // Update user in Firestore
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      // print('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  // Delete user by ID from Firestore
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      // print('Error deleting user: $e');
      throw Exception('Failed to delete user');
    }
  }

  Future<void> enrollStudent() async {
    final users = await fetchAllUsers().first;
    final courses = await _courseService.getAllCourses().first;
    // print("\x1B[33m Users: $users \x1B[0m");
    // print("\x1B[33m Courses: $courses \x1B[0m");

    for (var user in users) {
      if (user['role'] == 'Student') {
        var enrolledCourses = 0;
        // print('\x1B[37m ${user['role']}\x1B[0m');
        // print('\x1B[37m $enrolledCourses \x1B[0m');

        for (var course in courses) {
          if (user['year'] == course['year'] &&
              user['departmentId'] == course['departmentId']) {
            // print(
            //     "\x1B[32m Users: ${user['name']}  +  ${user['year']}  + ${user['departmentId']} \x1B[0m");
            // print("\x1B[35m Courses: $course \x1B[0m");
            if (!_isEnrolled(course, user) && !_isTaken(course, user)) {
              _enroll(course, user);
              enrolledCourses++;
              // print('\x1B[31m Enrolled \x1B[0m');
            }
          }
          if (enrolledCourses >= 5) {
            break;
          }
        }
      }
    }
  }

  void _enroll(Map<String, dynamic> course, Map<String, dynamic> user) async {
    user['enrolled_courses'] ??= [];
    user['enrolled_courses'].add(course);

    await _firestore.collection('users').doc(user['id']).update(user);
  }

  bool _isEnrolled(Map<String, dynamic> course, Map<String, dynamic> user) {
    // final enrolledCourses = user['enrolled_courses'] ?? [];
    // print(enrolledCourses);

    for (var enrolled in user['enrolled_courses']) {
      print(enrolled);
      if (enrolled['code'] == course['code']) {
        print("da5al");
        return true;
      }
    }
    return false;
  }

  bool _isTaken(Map<String, dynamic> course, Map<String, dynamic> user) {
    final takenCourses = user['taken_courses'] ?? [];
    for (var taken in takenCourses) {
      if (taken['code'] == course['code']) {
        return true;
      }
    }
    return false;
  }

  void enrollInstructor(dynamic userId, dynamic courseId) async {
    try {
      // Retrieve the user by ID
      final userDocRef = _firestore
          .collection('users')
          .doc(userId); // Reference to the user's document
      final userDoc = await userDocRef.get(); // Fetch the document snapshot

      if (userDoc.exists) {
        final courseDoc =
            await _firestore.collection('Courses').doc(courseId).get();

        if (courseDoc.exists) {
          // Check and update the enrolled_courses field
          List<dynamic> enrolledCourses =
              userDoc.data()?['enrolled_courses'] ?? [];

          // Fetch course data
          final courseData = courseDoc.data();
          final courseObject = {
            'id': courseDoc.id,
            'name': courseData?['name'],
            'code': courseData?['code'],
            'year': courseData?['year'],
            'departmentId': courseData?['departmentId'],
          };

          // Check if the course is already enrolled
          bool isEnrolled = enrolledCourses
              .any((course) => course['id'] == courseObject['id']);

          if (!isEnrolled) {
            // Add the course object if it is not already enrolled
            enrolledCourses.add(courseObject);

            // Update the user's document with the new enrolled_courses list
            await userDocRef.update({'enrolled_courses': enrolledCourses});
            print('Instructor enrolled successfully!');
          } else {
            print('Instructor is already enrolled in this course.');
          }
        } else {
          print('Course not found.');
        }
      } else {
        print('User does not exist.');
      }
    } catch (e) {
      // Error handling
      print('Failed to enroll instructor: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> fetchEnrolledCoursesByUserId(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      // Extract the list document's ID and fields, and create a usable map
      return [
        {
          'id': snapshot.id,
          'enrolled_courses': snapshot.data()?['enrolled_courses'],
        }
      ];
    });
  }
}
