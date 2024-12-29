import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<Question> questions;
  final String courseId;

  Quiz({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.questions,
    required this.courseId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'courseId': courseId,
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
      courseId: json['courseId'],
    );
  }

  /// Create a new quiz with a provided `id` instead of generating a UUID.
  factory Quiz.create({
    required String id, // Accept `id` as a parameter.
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required List<Question> questions,
    required String courseId,
  }) {
    return Quiz(
      id: id, // Use the provided `id`.
      title: title,
      startDate: startDate,
      endDate: endDate,
      questions: questions,
      courseId: courseId,
    );
  }
}
