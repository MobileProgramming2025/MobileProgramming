import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/widgets/Quiz/date_picker_field.dart';
import 'package:mobileprogramming/widgets/Quiz/options_editor.dart';
import 'package:mobileprogramming/widgets/Quiz/question_editor.dart'; // Renamed for clarity
class QuizCreationScreen extends StatefulWidget {
  final String courseId;  

  const QuizCreationScreen({super.key, required this.courseId});  

  @override
  State<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final QuizService _quizService = QuizService();

  String _quizTitle = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final List<Question> _questions = [];

  void _submitQuiz() async {
    if (_quizTitle.isEmpty || _questions.isEmpty || _startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please provide a title, at least one question, and a valid date range.'),
      ));
      return;
    }

    String quizId = DateTime.now().toIso8601String();
    Quiz quiz = Quiz(
      id: quizId,
      title: _quizTitle,
      startDate: _startDate,
      endDate: _endDate,
      questions: _questions,
      courseId: widget.courseId, 
    );

    await _quizService.createQuiz(quiz);

    if (!mounted) return;
    Navigator.pushNamed(context, '/attemptQuiz', arguments: quizId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => _quizTitle = value),
              decoration: const InputDecoration(labelText: 'Quiz Title'),
            ),
            DatePickerField(
              label: 'Start Date & Time',
              initialDateTime: _startDate,
              onDateTimeChanged: (dateTime) => setState(() => _startDate = dateTime),
            ),
            DatePickerField(
              label: 'End Date & Time',
              initialDateTime: _endDate,
              onDateTimeChanged: (dateTime) => setState(() => _endDate = dateTime),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return QuestionEditor(
                    question: _questions[index],
                    onChanged: (updatedQuestion) {
                      setState(() => _questions[index] = updatedQuestion);
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              child: const Text('Add Question'),
            ),
            ElevatedButton(
              onPressed: _submitQuiz,
              child: const Text('Create Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        Question(
          id: DateTime.now().toString(),
          text: '',
          type: 'multiple choice',
          options: ['Option 1', 'Option 2'],
          correctAnswer: '',
        ),
      );
    });
  }
}
