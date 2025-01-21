import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final UserService _userService = UserService();

  Stream<List<Map<String, dynamic>>> getAllCourses() {
    return FirebaseFirestore.instance
        .collection('Courses')
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

  Stream<List<Course>> getCoursesByDepartmentId(String departmentId) {
    try {
      return _firestore
          .collection('Courses')
          .where('departmentId', isEqualTo: departmentId)
          .snapshots() // Get real-time stream of query results
          .map((querySnapshot) {
        // Transform each QuerySnapshot into a List of Course objects
        return querySnapshot.docs.map((doc) {
          final data = doc
              .data(); // Extract Firestore document data as Map<String, dynamic>
          return Course.fromMap(data); // Pass the map directly to fromMap
        }).toList(); // Convert the Iterable to a List
      });
    } catch (e) {
      throw Exception('Failed to retrieve Course: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> gettCoursesByDepartmentId(
      String departmentId) {
    try {
      return _firestore
          .collection('Courses')
          .where('departmentId', isEqualTo: departmentId)
          .snapshots() // Get real-time stream of query results
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          // Extract the document's ID and fields, and create a usable map
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
      });
    } catch (e) {
      throw Exception('Failed to retrieve Course: $e');
    }
  }

  // add course to Firestore
  Future<void> addCourse({
    required String id,
    required String name,
    required String code,
    required String departmentId,
    required String year,
  }) async {
    try {
      final departmentQuerySnapshot = await _firestore
          .collection('Courses')
          .where('departmentId', isEqualTo: departmentId)
          .get();
      // Check for duplicate course name within the same department
      final nameQuerySnapshot = departmentQuerySnapshot.docs
          .where((doc) => doc['name'] == name)
          .toList();

      // Check for duplicate course code within the same department
      final codeQuerySnapshot = departmentQuerySnapshot.docs
          .where((doc) => doc['code'] == code)
          .toList();

      if (nameQuerySnapshot.isNotEmpty) {
        throw Exception("Course with name '$name' already exists.");
      }

      if (codeQuerySnapshot.isNotEmpty) {
        throw Exception("Course Code '$code' already exists.");
      }

      final docRef = await _firestore.collection('Courses').add({
        'name': name,
        'code': code,
        'departmentId': departmentId,
        'year': year,
      });
      // Update the document to set the 'id' field to match doc.id
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception("Failed to add Course: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> fetchEnrolledCoursesByUserId(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      // Extract the list of enrolled courses
      final enrolledCourses =
          snapshot.data()?['enrolled_courses'] as List<dynamic>?;

      // Map the enrolled courses into a list of maps with course data
      return enrolledCourses?.map((course) {
            return {
              'id': course['id'],
              'name': course['name'],
              'code': course['code'],
              'year': course['year'],
              'departmentId': course['departmentId'],
            };
          }).toList() ??
          []; // Return empty list if no taken courses
    });
  }

  Stream<List<Map<String, dynamic>>> fetchTakenCoursesByUserId(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      // Extract the list of taken courses
      final takenCourses = snapshot.data()?['taken_courses'] as List<dynamic>?;

      // Map the taken courses into a list of maps with course data
      return takenCourses?.map((course) {
            return {
              'id': course['id'],
              'name': course['name'],
              'code': course['code'],
              'year': course['year'],
              'departmentId': course['departmentId'],
            };
          }).toList() ??
          []; // Return empty list if no taken courses
    });
  }

  Future<bool> isCourseTaken(String courseId, String userId) async {
    final Stream<List<Map<String, dynamic>>> takenCoursesStream =
        fetchTakenCoursesByUserId(userId);
    // Wait for the data from the Stream to be available
    final List<Map<String, dynamic>> takenCourses =
        await takenCoursesStream.first;
    for (var taken in takenCourses) {
      if (taken['id'] == courseId) {
        return true;
      }
    }
    return false;
  }

  Future<bool> isEnrolledCoursesEmpty(String userId) async {
    final Stream<List<Map<String, dynamic>>> enrolledCoursesStream =
        fetchEnrolledCoursesByUserId(userId);
    // Wait for the data from the Stream to be available
    final List<Map<String, dynamic>> enrolledCourses =
        await enrolledCoursesStream.first;
    bool isEmpty = enrolledCourses.isEmpty; // Store the result in a variable
    return isEmpty; // Return the stored value
  }

  Future<Course?> getCourseById(String courseId) async {
    try {
      DocumentSnapshot courseDoc =
          await _firestore.collection('courses').doc(courseId).get();
      if (courseDoc.exists) {
        return Course.fromMap(courseDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting course by ID: $e');
      return null;
    }
  }

  Future<void> removeCourseFromUser(String userId, String courseId) async {
    try {
      // Retrieve the user by ID
      final userDocRef = _firestore
          .collection('users')
          .doc(userId); // Reference to the user's document
      bool isEnrolledEmpty = await isEnrolledCoursesEmpty(userId);

      if (!isEnrolledEmpty) {
        final enrolledCourses =
            await fetchEnrolledCoursesByUserId(userId).first;
        enrolledCourses.removeWhere((course) => course['id'] == courseId);

        // // Update the user's document with the new enrolled_courses list
        await userDocRef.update({'enrolled_courses': enrolledCourses});
      } else {
        throw Exception('This User doesn\' have any erolled courses');
      }
    } catch (e) {
      // Error handling
      throw Exception('Failed to remove course: $e');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    WriteBatch batch = _firestore.batch();

    try {
      // Delete the course document
      DocumentReference courseDocRef =
          _firestore.collection('Courses').doc(courseId);
      batch.delete(courseDocRef);

      // Remove the course from all users' enrolled_courses
      QuerySnapshot userQuerySnapshot =
          await _firestore.collection('users').get();
      for (DocumentSnapshot userDoc in userQuerySnapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<dynamic>? enrolledCourses = userData['enrolled_courses'];

        if (enrolledCourses != null) {
          enrolledCourses.removeWhere((course) => course['id'] == courseId);
          batch
              .update(userDoc.reference, {'enrolled_courses': enrolledCourses});
        }
      }

      // Delete assignments related to the course
      QuerySnapshot assignmentQuerySnapshot = await _firestore
          .collection('assignments')
          .where('courseId', isEqualTo: courseId)
          .get();
      for (DocumentSnapshot assignmentDoc in assignmentQuerySnapshot.docs) {
        batch.delete(assignmentDoc.reference);
      }

      // Delete quizzes related to the course
      QuerySnapshot quizQuerySnapshot = await _firestore
          .collection('quizzes')
          .where('courseId', isEqualTo: courseId)
          .get();
      for (DocumentSnapshot quizDoc in quizQuerySnapshot.docs) {
        batch.delete(quizDoc.reference);
      }

      // Commit the batch
      await batch.commit();
      print('Course deleted successfully with all related data.');
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }
}
