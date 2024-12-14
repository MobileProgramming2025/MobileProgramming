import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/QuizResult.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;

  QuizResultScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    double scorePercentage = (result.correctAnswers / result.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(title: Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Spent: ${result.timeSpent} seconds'),
            SizedBox(height: 20),
            Text('Correct Answers: ${result.correctAnswers} out of ${result.totalQuestions}'),
            SizedBox(height: 20),
            Text('Score: ${scorePercentage.toStringAsFixed(2)}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: Text('Back to Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
