// ignore_for_file: file_names

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


  Stream<List<Map<String, dynamic>>> getDoctorByDepartmentId(String departmentId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: "Doctor")
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
  }
}
