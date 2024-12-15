import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SubmissionService {
  final _submissionsCollection = FirebaseFirestore.instance.collection('Submissions');

  Future<void> submitAssignment(String assignmentId, String studentId, File file) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('Submissions/$assignmentId/${file.path.split('/').last}');
      await ref.putFile(file);
      final fileUrl = await ref.getDownloadURL();

      await _submissionsCollection.add({
        'assignmentId': assignmentId,
        'studentId': studentId,
        'fileUrl': fileUrl,
        'submittedAt': Timestamp.now(),
      });
      print("Submission uploaded successfully!");
    } catch (e) {
      print("Error uploading submission: $e");
    }
  }

  Future<void> editSubmission(String submissionId, File newFile) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('Submissions/$submissionId/${newFile.path.split('/').last}');
      await ref.putFile(newFile);
      final fileUrl = await ref.getDownloadURL();

      await _submissionsCollection.doc(submissionId).update({'fileUrl': fileUrl});
      print("Submission updated successfully!");
    } catch (e) {
      print("Error updating submission: $e");
    }
  }

  Stream<QuerySnapshot> getSubmissions(String assignmentId) {
    return _submissionsCollection.where('assignmentId', isEqualTo: assignmentId).snapshots();
  }
    Future<List<Map<String, dynamic>>> fetchSubmissionsByStudent(String studentId) async {
    final submissions = await FirebaseFirestore.instance
        .collection('Submissions')
        .where('studentId', isEqualTo: studentId)
        .get();
    return submissions.docs.map((doc) => doc.data()).toList();
  }

  Future<void> deleteSubmission(String submissionId) async {
    await FirebaseFirestore.instance.collection('Submissions').doc(submissionId).delete();
  }
   Future<List<Map<String, dynamic>>> fetchAllSubmissions() async {
    final submissions = await FirebaseFirestore.instance.collection('Submissions').get();
    return submissions.docs.map((doc) => doc.data()).toList();
  }
}
