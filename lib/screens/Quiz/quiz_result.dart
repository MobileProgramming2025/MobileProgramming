import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/QuizResult.dart';

class QuizResultScreen extends StatelessWidget {
  final QuizResult result;

  const QuizResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    double scorePercentage = (result.correctAnswers / result.totalQuestions) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time Spent: ${result.timeSpent} seconds'),
            const SizedBox(height: 20),
            Text('Correct Answers: ${result.correctAnswers} out of ${result.totalQuestions}'),
            const SizedBox(height: 20),
            Text('Score: ${scorePercentage.toStringAsFixed(2)}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: const Text('Back to Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
