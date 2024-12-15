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
      'duration': quiz.duration, // Store duration
    });
  }

  Future<List<Quiz>> getQuizzes() async {
    List<Quiz> quizzes = [];
    QuerySnapshot quizSnapshot = await _firestore.collection('quizzes').get();
    for (var doc in quizSnapshot.docs) {
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
        duration: doc['duration'] ?? 0,
      ));
    }
    return quizzes;
  }

  Future<Quiz> getQuiz(String quizId) async {
    DocumentSnapshot quizDoc = await _firestore.collection('quizzes').doc(quizId).get();
    List<Question> questions = (quizDoc['questions'] as List).map((q) {
      return Question(
        id: q['id'],
        text: q['text'],
        type: q['type'],
        options: q['options'] != null ? List<String>.from(q['options']) : null,
        correctAnswer: q['correctAnswer'],
      );
    }).toList();
    return Quiz(
      id: quizDoc.id,
      title: quizDoc['title'],
      questions: questions,
      duration: quizDoc['duration'] ?? 0,
    );
  }
}
