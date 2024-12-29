import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/services/quiz_service.dart';

class QuizDetailsScreen extends StatefulWidget {
  final Quiz quiz;
  

  const QuizDetailsScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizDetailsScreenState createState() => _QuizDetailsScreenState();
}

class _QuizDetailsScreenState extends State<QuizDetailsScreen> {
  late List<TextEditingController> questionControllers;
  late List<TextEditingController> answerControllers;
    final QuizService _quizService = QuizService(); 



  @override
  void initState() {
    super.initState();
   
    questionControllers = widget.quiz.questions
        .map((question) => TextEditingController(text: question.text))
        .toList();
    answerControllers = widget.quiz.questions
        .map((question) => TextEditingController(text: question.correctAnswer))
        .toList();
  }

  @override
  void dispose() {
    
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveChanges() async {
    
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      widget.quiz.questions[i].text = questionControllers[i].text;
      widget.quiz.questions[i].correctAnswer = answerControllers[i].text;
    }

  
    try {
      await _quizService.updateQuiz(widget.quiz);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              var question = widget.quiz.questions[index];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Question ${index + 1}:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: questionControllers[index],
                      decoration: InputDecoration(labelText: 'Edit Question'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: answerControllers[index],
                      decoration: InputDecoration(labelText: 'Edit Answer'),
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
