import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createQuiz(Quiz quiz) async {
    await _firestore.collection('quizzes').doc(quiz.id).set({
      'title': quiz.title,
      'questions': quiz.questions.map((q) => {
        'id': q.id,
        'text': q.text,
        'type': q.type,
        'options': q.options,
        'correctAnswer': q.correctAnswer,
      }).toList(),
    });
  }

  Future<List<Quiz>> getQuizzes() async {
    List<Quiz> quizzes = [];
    QuerySnapshot quizSnapshot = await _firestore.collection('quizzes').get();
    quizSnapshot.docs.forEach((doc) {
      List<Question> questions = (doc['questions'] as List).map((q) {
        return Question(
          id: q['id'],
          text: q['text'],
          type: q['type'],
          options: q['options'] != null ? List<String>.from(q['options']) : null,
          correctAnswer: q['correctAnswer'],
        );
      }).toList();
      quizzes.add(Quiz(
        id: doc.id,
        title: doc['title'],
        questions: questions,
      ));
    });
    return quizzes;
  }

  Future<List<Question>> getQuestions(String quizId) async {
    List<Question> questions = [];
    QuerySnapshot questionSnapshot = await _firestore.collection('quizzes')
        .doc(quizId)
        .collection('questions')
        .get();
    questionSnapshot.docs.forEach((doc) {
      questions.add(Question(
        id: doc['id'],
        text: doc['text'],
        type: doc['type'],
        options: doc['options'] != null ? List<String>.from(doc['options']) : null,
        correctAnswer: doc['correctAnswer'],
      ));
    });
    return questions;
  }
}
