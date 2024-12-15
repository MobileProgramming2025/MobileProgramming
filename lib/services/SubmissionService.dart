import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
class SubmissionService {
  final CollectionReference submissions = FirebaseFirestore.instance.collection('submissions');
   final FirebaseStorage _storage = FirebaseStorage.instance;
 Future<String> uploadFile(File file) async {
    final fileName = file.path.split('/').last;
    final ref = _storage.ref().child('submissions/$fileName');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
  Future<void> submitAssignment(Map<String, dynamic> data) async {
    await submissions.add(data);
  }

  Future<List<Map<String, dynamic>>> fetchSubmissions(String assignmentId) async {
    QuerySnapshot query = await submissions.where('assignmentId', isEqualTo: assignmentId).get();
    return query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> gradeSubmission(String submissionId, Map<String, dynamic> data) async {
    await submissions.doc(submissionId).update(data);
  }
}
