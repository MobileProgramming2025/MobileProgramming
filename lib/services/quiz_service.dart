import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<List<Quiz>> getQuizzesByUser(String userId) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .where('createdBy', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => Quiz.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (error) {
    throw Exception('Error fetching quizzes: $error');
  }
}
  /// Create a new quiz in Firestore
  Future<void> createQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).set({
        'title': quiz.title,
        'startDate': quiz.startDate.toIso8601String(),
        'endDate': quiz.endDate.toIso8601String(),
        'courseId': quiz.courseId,
        'questions': quiz.questions.map((q) => q.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  /// Fetch all quizzes from Firestore
  Future<List<Quiz>> getQuizzes() async {
    try {
      QuerySnapshot quizSnapshot = await _firestore.collection('quizzes').get();
      return quizSnapshot.docs.map((doc) {
        return Quiz(
          id: doc.id,
          title: doc['title'],
          startDate: DateTime.parse(doc['startDate']),
          endDate: DateTime.parse(doc['endDate']),
          courseId: doc['courseId'] ?? '',
          questions: _parseQuestions(doc['questions']),
          createdBy : doc['createdBy'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  /// Fetch a single quiz by ID from Firestore
  Future<Quiz> getQuiz(String quizId) async {
    try {
      DocumentSnapshot quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }
      return Quiz(
        id: quizDoc.id,
        title: quizDoc['title'],
        startDate: DateTime.parse(quizDoc['startDate']),
        endDate: DateTime.parse(quizDoc['endDate']),
        courseId: quizDoc['courseId'] ?? '',
        questions: _parseQuestions(quizDoc['questions']),
        createdBy : quizDoc['createdBy'],
      );
    } catch (e) {
      throw Exception('Failed to fetch quiz: $e');
    }
  }
  Future<Quiz?> getQuizById(String quizId) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(quizId)
        .get();

    if (doc.exists) {
      return Quiz.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null; // Return null if quiz doesn't exist
  } catch (error) {
    rethrow; // Let the caller handle the error
  }
}


  /// Parse questions from Firestore data
  List<Question> _parseQuestions(dynamic questionsData) {
    if (questionsData is List) {
      return questionsData.map((q) {
        return Question(
          id: q['id'],
          text: q['text'],
          type: q['type'],
          options: q['options'] != null ? List<String>.from(q['options']) : null,
          correctAnswer: q['correctAnswer'],
        );
      }).toList();
    }
    return [];
  }
Future<void> updateQuiz(Quiz quiz) async {
  try {
    // Create a map of the updated quiz data
    final quizData = {
      'title': quiz.title,
      'startDate': quiz.startDate.toIso8601String(),
      'endDate': quiz.endDate.toIso8601String(),
      'courseId': quiz.courseId,
      'questions': quiz.questions.map((q) => q.toJson()).toList(),
    };

    // Update the quiz document in Firestore
    await _firestore.collection('quizzes').doc(quiz.id).update(quizData);
  } catch (e) {
    throw Exception('Failed to update quiz: $e');
  }
}


  Future<void> deleteQuiz(String quizId) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).delete();
    } catch (error) {
      throw Exception('Failed to delete quiz: $error');
    }
  }
}
