import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/AttemptQuiz.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/models/Question.dart';

class AttemptQuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String userId;
  final String courseId; // Add courseId here

  const AttemptQuizScreen({
    super.key,
    required this.quiz,
    required this.userId,
    required this.courseId, // Include it in the constructor
  });

  @override
  State<AttemptQuizScreen> createState() => _AttemptQuizScreenState();
}

class _AttemptQuizScreenState extends State<AttemptQuizScreen> {
  final Map<String, dynamic> _userAnswers = {};

  // Submit the quiz and calculate score
  void _submitQuiz() {
    int score = 0;

    for (var question in widget.quiz.questions) {
      final userAnswer = _userAnswers[question.id];
      if (userAnswer != null && userAnswer == question.correctAnswer) {
        score++;
      }
    }

    final totalQuestions = widget.quiz.questions.length;
    final percentage = (score / totalQuestions) * 100;

    // Create a new QuizAttempt instance
    final quizAttempt = QuizAttempt(
      userId: widget.userId,
      quizId: widget.quiz.id,
      courseId: widget.courseId,  // Add courseId to the QuizAttempt
      userAnswers: _userAnswers.map((key, value) => MapEntry(key, value as String)),
      score: score,
      percentage: percentage,
      timestamp: DateTime.now(),
    );

    // Save the quiz attempt to Firestore
    FirebaseFirestore.instance.collection('quizAttempts').add(quizAttempt.toJson());

    // Show the result to the user
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Result'),
        content: Text(
          'You scored $score out of $totalQuestions (${percentage.toStringAsFixed(2)}%).',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the result dialog
              Navigator.pop(context); // Go back to the previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Build the question widget based on the type
  Widget _buildQuestionWidget(Question question) {
    if (question.type == 'multiple_choice' && question.options != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          question.options!.length,
          (index) {
            final option = question.options![index];
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _userAnswers[question.id],
              onChanged: (value) {
                setState(() {
                  _userAnswers[question.id] = value;
                });
              },
            );
          },
        ),
      );
    } else if (question.type == 'text') {
      return TextField(
        onChanged: (value) {
          setState(() {
            _userAnswers[question.id] = value;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Your Answer',
          border: OutlineInputBorder(),
        ),
      );
    } else {
      return const Text('Unsupported question type.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attempt Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quiz.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start Date: ${widget.quiz.startDate}\nEnd Date: ${widget.quiz.endDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Questions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question.text}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          _buildQuestionWidget(question),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitQuiz,
              child: const Text('Submit Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
