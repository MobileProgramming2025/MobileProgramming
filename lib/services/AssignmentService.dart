import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:mobileprogramming/models/assignment_model.dart';

class ApiService {
  final String baseUrl;
  final String userId; // Pass the signed-in doctor's ID

  ApiService({required this.baseUrl, required this.userId});

  Future<List<Assignment>> getAssignments(String courseId) async {
    final response = await http.get(Uri.parse('$baseUrl/assignments?courseId=$courseId&createdBy=$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Assignment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load assignments');
    }
  }

  Future<void> createAssignment(Assignment assignment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assignments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': assignment.title,
        'description': assignment.description,
        'courseId': assignment.courseId,
        'createdBy': userId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create assignment');
    }
  }

//   Future<List<Map<String, dynamic>>> getAssignmentsByUser(String userId) async {
//   try {
//     QuerySnapshot snapshot = await FirebaseFirestore.instance
//         .collection('assignments')
//         .where('createdBy', isEqualTo: userId)
//         .orderBy('dueDateTime') // Sort by deadline
//         .get();

//     return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
//   } catch (error) {
//     throw Exception('Error fetching assignments for user: $error');
//   }
// }



}
