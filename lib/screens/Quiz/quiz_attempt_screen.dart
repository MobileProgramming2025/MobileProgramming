import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Quiz.dart';
// import 'package:mobileprogramming/models/QuizResult.dart';
// import 'package:mobileprogramming/screens/Quiz/quiz_result.dart';
import 'package:mobileprogramming/services/quiz_service.dart';

class QuizAttemptScreen extends StatefulWidget {
  final String quizId;

  const QuizAttemptScreen({super.key, required this.quizId});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  final QuizService _quizService = QuizService();
  late Quiz _quiz;
  int _remainingTime = 0;
  final Map<int, String?> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    // _quiz = await _quizService.getQuiz(widget.quizId);
    // setState(() {
    //   _remainingTime = _quiz.duration;
    // });

    // _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
        _startTimer();
      } else {
        _showTimeoutDialog();
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Time Up!'),
          content: const Text('You have run out of time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _submitQuiz() {
 
  //  final int timeSpent = _quiz.duration - _remainingTime;

    int correctAnswers = 0;
    for (var index = 0; index < _quiz.questions.length; index++) {
      if (_quiz.questions[index].correctAnswer == _userAnswers[index]) {
        correctAnswers++;
      }
    }

    // final result = QuizResult(
    // //  timeSpent: timeSpent,
    //   correctAnswers: correctAnswers,
    //   totalQuestions: _quiz.questions.length,
    // );

   // Navigator.push(
     // context,
    //  MaterialPageRoute(
     //   builder: (context) => QuizResultScreen(result: result),
     // ),
   // );
 // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_quiz.title)),
      body: Column(
        children: [
          Text('Time Remaining: $_remainingTime seconds'),
          Expanded(
            child: ListView.builder(
              itemCount: _quiz.questions.length,
              itemBuilder: (context, index) {
                final question = _quiz.questions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (question.type == 'multiple choice') 
                          Column(
                            children: question.options!.map((option) {
                              return RadioListTile<String?>(
                                title: Text(option),
                                value: option,
                                groupValue: _userAnswers[index],
                                onChanged: (value) {
                                  setState(() {
                                    _userAnswers[index] = value;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        if (question.type == 'short answer')
                          TextField(
                            onChanged: (value) {
                              _userAnswers[index] = value;
                            },
                            decoration: const InputDecoration(labelText: 'Your Answer'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitQuiz,
            child: const Text('Submit Quiz'),
          ),
        ],
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}