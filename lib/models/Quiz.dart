import 'package:mobileprogramming/models/Question.dart';

// class Quiz {
//    String id;
//    String title;
//    DateTime startDate;
//    DateTime endDate;
//    List<Question> questions;
//    String courseId;

//   Quiz({
//     required this.id,
//     required this.title,
//     required this.startDate,
//     required this.endDate,
//     required this.questions,
//     required this.courseId,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'startDate': startDate.toIso8601String(),
//       'endDate': endDate.toIso8601String(),
//       'questions': questions.map((q) => q.toJson()).toList(),
//       'courseId': courseId,
//     };
//   }

//   factory Quiz.fromJson(Map<String, dynamic> json) {
//     return Quiz(
//       id: json['id'],
//       title: json['title'],
//       startDate: DateTime.parse(json['startDate']),
//       endDate: DateTime.parse(json['endDate']),
//       questions: (json['questions'] as List<dynamic>)
//           .map((q) => Question.fromJson(q))
//           .toList(),
//       courseId: json['courseId'],
//     );
//   }

//   factory Quiz.create({
//     required String id,
//     required String title,
//     required DateTime startDate,
//     required DateTime endDate,
//     required List<Question> questions,
//     required String courseId,
//   }) {
//     return Quiz(
//       id: id, 
//       title: title,
//       startDate: startDate,
//       endDate: endDate,
//       questions: questions,
//       courseId: courseId,
//     );
//   }
// }
class Quiz {
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final List<Question> questions;
  final String courseId;
  final String createdBy; // Field for the user who created the quiz

  Quiz({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.questions,
    required this.courseId,
    required this.createdBy,
  });

  /// Factory constructor to create a Quiz from JSON.
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      courseId: json['courseId'],
      createdBy: json['createdBy'], // Parse the creator's ID or name
    );
  }

  /// Converts the Quiz object to a JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'courseId': courseId,
      'createdBy': createdBy, // Include the creator's field
    };
  }

  /// Factory method to create a new Quiz instance.
  factory Quiz.create({
    required String id,
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required List<Question> questions,
    required String courseId,
    required String createdBy,
  }) {
    return Quiz(
      id: id,
      title: title,
      startDate: startDate,
      endDate: endDate,
      questions: questions,
      courseId: courseId,
      createdBy: createdBy,
    );
  }
}
