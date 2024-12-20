import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  final String id;
  final String title;
  final DateTime startDate; 
  final DateTime endDate; 
  final String courseId;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.courseId,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),  
      'courseId': courseId,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}
