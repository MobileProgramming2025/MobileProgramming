import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDoctor({
    required String name,
    required String email,
    required String specialization,
  }) async {
    try {
      await _firestore.collection('doctors').add({
        'name': name,
        'email': email,
        'specialization': specialization,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add doctor: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> fetchDoctors() {
    return _firestore.collection('doctors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  Future<void> updateDoctor({
    required String id,
    required String name,
    required String email,
    required String specialization,
  }) async {
    try {
      await _firestore.collection('doctors').doc(id).update({
        'name': name,
        'email': email,
        'specialization': specialization,
      });
    } catch (e) {
      throw Exception("Failed to update doctor: $e");
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      await _firestore.collection('doctors').doc(id).delete();
    } catch (e) {
      throw Exception("Failed to delete doctor: $e");
    }
  }
}
