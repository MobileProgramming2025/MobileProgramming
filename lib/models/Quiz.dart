import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  final String id;
  final String title;
  final int duration; 
  final String courseId;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.duration,
    required this.courseId,
    required this.questions,
  });

 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'courseId': courseId,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }
}