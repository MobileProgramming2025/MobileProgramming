import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/auth_service.dart';

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

  Future<void> enrollUserToCourses(dynamic userId, dynamic courseId) async {
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
          List<dynamic> enrolledCourses = userDoc.data()?['enrolled_courses'];

          // Fetch course data
          final courseData = courseDoc.data();
          if (courseData == null) {
            throw Exception('Course data is invalid.');
          }
          final courseObject = {
            'id': courseDoc.id,
            'name': courseData['name'],
            'code': courseData['code'],
            'year': courseData['year'],
            'departmentId': courseData['departmentId'],
          };

          // Check if the course is already enrolled
          bool isEnrolled = enrolledCourses
              .any((course) => course['id'] == courseObject['id']);

          if (!isEnrolled) {
            // Add the course object if it is not already enrolled
            enrolledCourses.add(courseObject);

            // Update the user's document with the new enrolled_courses list
            await userDocRef.update({'enrolled_courses': enrolledCourses});
          } else {
            throw Exception('Instructor is already enrolled in this course.');
          }
        } else {
          throw Exception('Course not found.');
        }
      } else {
        throw Exception('User does not exist.');
      }
    } catch (e) {
      // Error handling
      throw Exception('Failed to enroll instructor: $e');
    }
  }

  void logout(context) async {
    final AuthService authService = AuthService();
  final colorScheme = Theme.of(context).colorScheme;

    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout",
          style: TextStyle(color: colorScheme.primary),
          ),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel",
              style: TextStyle(color: colorScheme.primary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Logout",
              style: TextStyle(color: colorScheme.error),

              ),
            ),
          ],
        backgroundColor: colorScheme.surface,

        );
      },
    );

    if (confirmLogout == true) {
      try {
        await authService.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logged out successfully")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to log out: $e")),
        );
      }
    }
  }
  // Search for user by email
  Future<User?> searchUserByEmail(String email) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null; // No user found
      } else {
        final userDoc = querySnapshot.docs.first;
        return User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // print('Error searching for user by email: $e');
      throw Exception('Failed to search user by email');
    }
  }

  Future<User?> fetchUserByEmail(String email) async {
    try {
      // Search for the user by email in Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // No user found with the given email
        throw Exception("User not found");
      }

      // Assuming there's only one user with this email, you can get the first document
      final doc = querySnapshot.docs.first;

      // Convert the document into a User object
      return User.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      // Handle any errors that occur
      rethrow;
    }
  }

}
