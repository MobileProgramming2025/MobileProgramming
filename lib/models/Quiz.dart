import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  String id; // Unique identifier for the quiz
  String title; // Title of the quiz
  DateTime startDate; // Start date and time of the quiz
  Duration duration; // Duration of the quiz
  List<Question> questions; // List of questions in the quiz
  String courseId; // ID of the associated course
  String createdBy; // Name or ID of the creator (e.g., doctor or teacher)

  Quiz({
    required this.id,
    required this.title,
    required this.startDate,
    required this.duration,
    required this.questions,
    required this.courseId,
    required this.createdBy,
  });

  /// Factory constructor to create a Quiz instance from JSON data
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      duration: Duration(
        hours: (json['duration']['hours'] ?? 0) as int,
        minutes: (json['duration']['minutes'] ?? 0) as int,
      ),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      courseId: json['courseId'] as String,
      createdBy: json['createdBy'] as String,
    );
  }

  /// Converts a Quiz instance into a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startDate': startDate.toIso8601String(),
      'duration': {
        'hours': duration.inHours,
        'minutes': duration.inMinutes % 60,
      },
      'questions': questions.map((q) => q.toJson()).toList(),
      'courseId': courseId,
      'createdBy': createdBy,
    };
  }

  /// Convenience factory method to create a Quiz instance
  factory Quiz.create({
    required String id,
    required String title,
    required DateTime startDate,
    required Duration duration,
    required List<Question> questions,
    required String courseId,
    required String createdBy,
  }) {
    return Quiz(
      id: id,
      title: title,
      startDate: startDate,
      duration: duration,
      questions: questions,
      courseId: courseId,
      createdBy: createdBy,
    );
  }

  /// Creates a copy of the Quiz instance with updated values
  Quiz copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    Duration? duration,
    List<Question>? questions,
    String? courseId,
    String? createdBy,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      courseId: courseId ?? this.courseId,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  /// Calculates the end date and time of the quiz
  DateTime get endDate => startDate.add(duration);

  /// Determines if the quiz is currently active based on the current time
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }
}
