import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/services/quiz_service.dart';

class QuizDetailsScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizDetailsScreen({super.key, required this.quiz});

  @override
  State<QuizDetailsScreen> createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {
  late List<TextEditingController> questionControllers;
  late List<TextEditingController> answerControllers;
  final QuizService _quizService = QuizService();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing question and answer data
    questionControllers = widget.quiz.questions
        .map((question) => TextEditingController(text: question.text))
        .toList();
    answerControllers = widget.quiz.questions
        .map((question) => TextEditingController(text: question.correctAnswer))
        .toList();
  }

  @override
  void dispose() {
    // Dispose of all controllers to free resources
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Update quiz questions with modified text and answers
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      widget.quiz.questions[i].text = questionControllers[i].text;
      widget.quiz.questions[i].correctAnswer = answerControllers[i].text;
    }

    try {
      // Call service to update the quiz
      await _quizService.updateQuiz(widget.quiz);
      _showSnackBar('Changes saved successfully!');
    } catch (e) {
      _showSnackBar('Failed to save changes: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Title: ${widget.quiz.title}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Start Date: ${widget.quiz.startDate.toString()}'),
              Text('End Date: ${widget.quiz.endDate.toString()}'),
              const SizedBox(height: 16),
              const Text(
                'Questions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...List.generate(widget.quiz.questions.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• Question ${index + 1}:',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextField(
                        controller: questionControllers[index],
                        decoration:
                            const InputDecoration(labelText: 'Edit Question'),
                        maxLines: 2,
                      ),
                      TextField(
                        controller: answerControllers[index],
                        decoration:
                            const InputDecoration(labelText: 'Edit Answer'),
                        maxLines: 2,
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
