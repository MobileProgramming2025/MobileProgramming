class QuizAttempt {
  final String userId;
  final String quizId;
  final String courseId; // Add courseId
  final Map<String, String> userAnswers;
  final int score;
  final double percentage;
  final DateTime timestamp;

  QuizAttempt({
    required this.userId,
    required this.quizId,
    required this.courseId,  // Include courseId in constructor
    required this.userAnswers,
    required this.score,
    required this.percentage,
    required this.timestamp,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'quizId': quizId,
      'courseId': courseId, // Include courseId in toJson method
      'userAnswers': userAnswers,
      'score': score,
      'percentage': percentage,
      'timestamp': timestamp,
    };
  }
}
