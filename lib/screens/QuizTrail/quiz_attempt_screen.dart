import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';

class QuizAttemptScreen extends StatelessWidget {
  final String courseId;
  final String userId;

  const QuizAttemptScreen({
    super.key,
    required this.courseId,
    required this.userId,
  });

  // Fetch quizzes from Firestore and map to the Quiz model
  Future<List<Quiz>> _fetchQuizzes() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .where('courseId', isEqualTo: courseId)
        .get();

    // Map Firestore documents to Quiz objects
    return querySnapshot.docs
        .map((doc) => Quiz.fromJson(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Attempt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Quiz>>(
          future: _fetchQuizzes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return const Center(child: Text('No quizzes available for this course.'));
            }

            // Display quizzes
            final quizzes = snapshot.data!;
            return ListView.builder(
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(quiz.title),
                    subtitle: Text(
                      'Starts: ${quiz.startDate}\nEnds: ${quiz.endDate}',
                    ),
                    onTap: () {
                      // Navigate to quiz attempt screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttemptQuizScreen(
                            quiz: quiz,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AttemptQuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String userId;

  const AttemptQuizScreen({
    super.key,
    required this.quiz,
    required this.userId,
  });

  @override
  State<AttemptQuizScreen> createState() => _AttemptQuizScreenState();
}

class _AttemptQuizScreenState extends State<AttemptQuizScreen> {
  final Map<String, dynamic> _userAnswers = {};

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

    // Save result to Firestore
    FirebaseFirestore.instance.collection('quizAttempts').add({
      'userId': widget.userId,
      'quizId': widget.quiz.id,
      'score': score,
      'percentage': percentage,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Show result
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
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to the previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
