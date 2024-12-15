import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/services/quiz_service.dart';

class ScoreReviewScreen extends StatefulWidget {
  final String quizId;

  const ScoreReviewScreen({super.key, required this.quizId});

  @override
  _ScoreReviewScreenState createState() => _ScoreReviewScreenState();
}

class _ScoreReviewScreenState extends State<ScoreReviewScreen> {
  final QuizService _quizService = QuizService();
  final List<Question> _questions = [];
  final List<String> _studentAnswers = [];
  final List<String> _correctAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  void _loadReview() async {
 
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Quiz')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_questions[index].text),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your answer: ${_studentAnswers[index]}'),
                      Text('Correct answer: ${_correctAnswers[index]}'),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Close Review'),
          ),
        ],
      ),
    );
  }
}
