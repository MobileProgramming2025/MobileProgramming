import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Question.dart';

class QuestionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addQuestion(String quizId, Question question) async {
    await _firestore.collection('quizzes').doc(quizId).collection('questions').doc(question.id).set({
      'text': question.text,
      'type': question.type,
      'options': question.options,
      'correctAnswer': question.correctAnswer,
    });
  }

  Future<List<Question>> getQuestions(String quizId) async {
    List<Question> questions = [];
    QuerySnapshot questionSnapshot = await _firestore.collection('quizzes').doc(quizId).collection('questions').get();
    for (var doc in questionSnapshot.docs) {
      questions.add(Question(
        id: doc.id,
        text: doc['text'],
        type: doc['type'],
        options: doc['options'] != null ? List<String>.from(doc['options']) : null,
        correctAnswer: doc['correctAnswer'],
      ));
    }
    return questions;
  }
}
