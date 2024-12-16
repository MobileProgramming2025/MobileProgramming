import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  final String id;
  final String title;
<<<<<<< Updated upstream
  final int duration; 
=======
  final int duration; // Duration in minutes
>>>>>>> Stashed changes
  final String courseId;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.duration,
    required this.courseId,
    required this.questions,
  });

  // Convert to Map for Firestore
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