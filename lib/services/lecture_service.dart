import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lecture.dart';

class LectureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save a lecture to Firestore
  Future<void> addLecture(Lecture lecture) async {
    try {
      await _firestore.collection('lectures').add(lecture.toMap());
    } catch (e) {
      throw Exception('Failed to add lecture: $e');
    }
  }

  // Fetch all lectures for a specific course
  Future<List<Lecture>> getLecturesByCourse(String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('lectures')
          .where('course_id', isEqualTo: courseId)
          .get();

      return querySnapshot.docs
          .map((doc) => Lecture.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lectures: $e');
    }
  }

  // Delete a lecture by document ID
  Future<void> deleteLecture(String lectureId) async {
    try {
      await _firestore.collection('lectures').doc(lectureId).delete();
    } catch (e) {
      throw Exception('Failed to delete lecture: $e');
    }
  }
}
