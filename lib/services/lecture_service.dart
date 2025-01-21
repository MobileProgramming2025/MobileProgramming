import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lecture.dart';

class LectureService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Save a lecture to Firestore
  Future<void> addLecture(Lecture lecture) async {
    try {
      await _firestore.collection('lectures').add(lecture.toMap());
    } catch (e) {
      throw Exception('Failed to add lecture: $e');
    }
  }

  // Fetch all lectures for a specific course from Firestore and add signed URLs from Supabase
  Future<List<Lecture>> getLecturesByCourse(String courseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('lectures')
          .where('course_id', isEqualTo: courseId)
          .get();

      return await Future.wait(querySnapshot.docs.map((doc) async {
        final lectureData = doc.data();
        final filePath = lectureData['file_path'] as String?;

        String? signedUrl;

        if (filePath != null) {
          try {
            signedUrl = await _supabase.storage
                .from('lecture-files')
                .createSignedUrl(filePath, 3600); // Expires in 1 hour
          } catch (e) {
            print('Failed to generate signed URL for $filePath: $e');
          }
        }

        lectureData['file_url'] = signedUrl ?? ''; // Set empty string if null

        return Lecture.fromMap(lectureData);
      }).toList());
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
