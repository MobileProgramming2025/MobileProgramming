import 'package:cloud_firestore/cloud_firestore.dart';

class TaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getAllTa() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: "Teaching Assistant")
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
}