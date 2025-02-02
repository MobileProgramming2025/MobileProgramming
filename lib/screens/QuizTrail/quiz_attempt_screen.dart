import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:mobileprogramming/models/AttemptQuiz.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/models/Question.dart';

class AttemptQuizScreen extends StatefulWidget {
  final Quiz quiz;
  final String userId;
  final String courseId;

  const AttemptQuizScreen({
    super.key,
    required this.quiz,
    required this.userId,
    required this.courseId,
  });

  @override
  State<AttemptQuizScreen> createState() => _AttemptQuizScreenState();
}

class _AttemptQuizScreenState extends State<AttemptQuizScreen> {
  final Map<String, dynamic> _userAnswers = {};
  late Timer _timer;
  late Duration _remainingTime;
  bool _isTimeUp = false;
  bool _quizAlreadyAttempted = false;

  @override
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final quizStartDate = widget.quiz.startDate;
    final quizEndDate = widget.quiz.endDate;

    if (now.isBefore(quizStartDate)) {
      _isTimeUp = true;
      Future.microtask(() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quiz Not Started'),
            content: Text(
                'This quiz will start on ${quizStartDate.toLocal().toString().split(' ')[0]} at ${quizStartDate.toLocal().toString().split(' ')[1]}. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); 
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
      return;
    }

    _checkIfQuizAlreadyAttempted();

    _remainingTime = quizEndDate.difference(now);

    if (_remainingTime.isNegative) {
      _remainingTime = Duration(seconds: 0);
      _isTimeUp = true;
      _saveQuizAttempt();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _isTimeUp = true;
          _timer.cancel();
          _saveQuizAttempt();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkIfQuizAlreadyAttempted() async {
    final quizAttemptsQuery = FirebaseFirestore.instance
        .collection('quizAttempts')
        .where('userId', isEqualTo: widget.userId)
        .where('quizId', isEqualTo: widget.quiz.id);

    final querySnapshot = await quizAttemptsQuery.get();

    if (querySnapshot.docs.isNotEmpty) {
      final attempt = querySnapshot.docs.first; // Get the first attempt
      final attemptTimestamp = attempt['timestamp'].toDate();

      final quizEndDate = widget.quiz.endDate;
      if (quizEndDate.isBefore(DateTime.now())) {
        setState(() {
          _quizAlreadyAttempted = true;
          _isTimeUp = true;
        });
      } else {
        setState(() {
          _quizAlreadyAttempted = true;
          _isTimeUp = false;
          
          _userAnswers
              .addAll(Map<String, dynamic>.from(attempt['userAnswers']));
        });
      }
    } else {
      setState(() {
        _quizAlreadyAttempted = false;
        _isTimeUp = false;
      });
    }
  }

void _saveQuizAttempt() {
  if (_quizAlreadyAttempted || _isTimeUp) {
    return;
  }

  int score = 0;

  for (var question in widget.quiz.questions) {
    final userAnswer = _userAnswers[question.id];
    if (userAnswer != null && userAnswer == question.correctAnswer) {
      score++;
    }
  }

  final totalQuestions = widget.quiz.questions.length;
  final percentage = (score / totalQuestions) * 100;

  final quizAttempt = QuizAttempt(
    userId: widget.userId,
    quizId: widget.quiz.id,
    courseId: widget.courseId,
    userAnswers:
        _userAnswers.map((key, value) => MapEntry(key, value as String)),
    score: score,
    percentage: percentage,
    timestamp: DateTime.now(),
  );

  FirebaseFirestore.instance
      .collection('quizAttempts')
      .add(quizAttempt.toJson());

  if (!_isTimeUp && !_quizAlreadyAttempted) {
    Navigator.pop(context);
  }
}

  void _submitQuiz() {
    if (_isTimeUp || _quizAlreadyAttempted) {
      return;
    }
    _saveQuizAttempt();
  }

  Widget _buildQuestionWidget(Question question) {
    if (question.type == 'multiple choice' && question.options != null) {
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
    } else if (question.type == 'true/false') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('True'),
              ),
              Radio<String>(
                value: 'True',
                groupValue: _userAnswers[question.id],
                onChanged: (value) {
                  setState(() {
                    _userAnswers[question.id] = value!;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text('False'),
              ),
              Radio<String>(
                value: 'False',
                groupValue: _userAnswers[question.id],
                onChanged: (value) {
                  setState(() {
                    _userAnswers[question.id] = value!;
                  });
                },
              ),
            ],
          ),
        ],
      );
    } else if (question.type == 'short answer') {
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
    } else if (question.type == 'matching') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Match the following:'),
          ...question.options!.asMap().entries.map((entry) {
            int index = entry.key;
            String option = entry.value;
            return Row(
              children: [
                Expanded(
                  child: Text(option),
                ),
                DropdownButton<String>(
                  value: _userAnswers[question.id]?[index] ?? '',
                  items: question.options!
                      .map((e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _userAnswers[question.id]?[index] = value;
                    });
                  },
                ),
              ],
            );
          }).toList(),
        ],
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
            !_quizAlreadyAttempted && !_isTimeUp
                ? Text(
                    'Time remaining: ${_remainingTime.inHours}:${(_remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            _quizAlreadyAttempted || _isTimeUp
                ? const Text('The quiz is up! You can\'t attempt again.')
                : Expanded(
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
              onPressed:
                  _isTimeUp || _quizAlreadyAttempted ? null : _submitQuiz,
              child: const Text('Submit Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
