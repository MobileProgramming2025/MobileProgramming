import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Quiz>> getQuizzesByUser(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .where('createdBy', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => Quiz.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Exception('Error fetching quizzes by user: $error');
    }
  }

  Future<void> createQuiz(Quiz quiz) async {
    try {
      await _firestore.collection('quizzes').doc(quiz.id).set({
        'title': quiz.title,
        'startDate': quiz.startDate.toIso8601String(),
        'duration': quiz.duration.inSeconds, // Store duration in seconds
        'courseId': quiz.courseId,
        'createdBy': quiz.createdBy,
        'questions': quiz.questions.map((q) => q.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to create quiz: $e');
    }
  }

  Future<List<Quiz>> getQuizzes() async {
    try {
      QuerySnapshot quizSnapshot = await _firestore.collection('quizzes').get();
      return quizSnapshot.docs.map((doc) {
        return Quiz.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  Future<Quiz> getQuiz(String quizId) async {
    try {
      DocumentSnapshot quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
      if (!quizDoc.exists) {
        throw Exception('Quiz not found');
      }
      return Quiz.fromJson(quizDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch quiz: $e');
    }
  }

  Future<Quiz?> getQuizById(String quizId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        return Quiz.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateQuiz(Quiz quiz) async {
    try {
      final quizData = {
        'title': quiz.title,
        'startDate': quiz.startDate.toIso8601String(),
        'duration': quiz.duration.inSeconds, // Store duration in seconds
        'courseId': quiz.courseId,
        'createdBy': quiz.createdBy,
        'questions': quiz.questions.map((q) => q.toJson()).toList(),
      };

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

  // Fetch quizzes by courseId
  Future<List<Quiz>> fetchQuizzesByCourseId(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .where('courseId', isEqualTo: courseId) // Filter by courseId
          .get();

      return snapshot.docs
          .map((doc) => Quiz.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching quizzes by courseId: $e');
    }
  }

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
}
