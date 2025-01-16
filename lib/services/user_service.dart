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

  //Each data item in the stream is a list of maps. Each map represents a doctor’s details.
//list  of doctors as there maybe more than one doctor and map will include the details of the dr as name,email,..
  Stream<List<Map<String, dynamic>>> fetchDoctors() {
    //.snapshots(): creates a stream ashan lama ay update (any crud of dr in firestore) ysamaa ala tol
    //A snapshot represents a "snapshot" of the current state of the database at that moment and contains all the documents in drs collection.
    //.map() is used to transform the raw snapshot data into map that includes all dr details
    return _firestore
        .collection('users')
        .where('role', isEqualTo: "Doctor")
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
    print("\x1B[33m Users: $users \x1B[0m");
    print("\x1B[33m Courses: $courses \x1B[0m");

    for (var user in users) {
      if (user['role'] == 'Student') {
        var enrolledCourses = 0;
        print('\x1B[37m ${user['role']}\x1B[0m');
        print('\x1B[37m $enrolledCourses \x1B[0m');

        for (var course in courses) {
          if (user['year'] == course['year'] &&
              user['departmentId'] == course['departmentId']) {
            print(
                "\x1B[32m Users: ${user['name']}  +  ${user['year']}  + ${user['departmentId']} \x1B[0m");
            print("\x1B[35m Courses: $course \x1B[0m");
            if (!_isEnrolled(course, user) && !_isTaken(course, user)) {
              _enroll(course, user);
              enrolledCourses++;
              print('\x1B[31m Enrolled \x1B[0m');
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
}
