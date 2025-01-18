import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/Quiz/QuizEditScreen.dart';
import 'package:mobileprogramming/screens/QuizTrail/QuizEditScreen.dart';

class QuizDetailsScreen extends StatelessWidget {
  final Quiz quiz;
  final String courseId;

  const QuizDetailsScreen({super.key, required this.quiz, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizEditScreen(quizId: quiz.id, courseId:courseId ,),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Quiz Title: ${quiz.title}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Start Date: ${quiz.startDate.toLocal()}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'End Date: ${quiz.startDate.add(quiz.duration).toLocal()}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            const Text(
              'Questions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...quiz.questions.map((question) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question: ${question.text}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    ...question.options!.map((option) {
                      return Text(
                        'Option: $option',
                        style: const TextStyle(fontSize: 14),
                      );
                    }).toList(),
                    Text(
                      'Correct Answer: ${question.correctAnswer}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz details or take other actions
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
