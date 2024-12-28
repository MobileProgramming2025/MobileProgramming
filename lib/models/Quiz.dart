
import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<Question> questions;
  final String courseId; // Add this field

  Quiz({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.questions,
    required this.courseId, // Add it to the constructor
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'courseId': courseId, // Include in JSON
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q))
          .toList(),
      courseId: json['courseId'], // Parse from JSON
    );
  }
}
