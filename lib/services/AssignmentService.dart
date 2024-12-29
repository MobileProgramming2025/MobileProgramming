import 'dart:convert';
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
}
