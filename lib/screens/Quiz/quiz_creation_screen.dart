import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/Quiz/QuizDetailsScreen.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/widgets/Quiz/date_picker_field.dart';
import 'package:mobileprogramming/widgets/Quiz/options_editor.dart';
import 'package:mobileprogramming/widgets/Quiz/question_editor.dart';
import 'package:uuid/uuid.dart';

class QuizCreationScreen extends StatefulWidget {
  final String courseId;

  const QuizCreationScreen({super.key, required this.courseId});

  @override
  State<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final QuizService _quizService = QuizService();
  final PageController _pageController = PageController();
  final Uuid _uuid = Uuid();

  String _quizTitle = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final List<Question> _questions = [];

void _submitQuiz() async {
  if (_quizTitle.isEmpty || _questions.isEmpty || _startDate.isAfter(_endDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Please provide a title, at least one question, and a valid date range.'),
      ),
    );
    return;
  }

  Quiz quiz = Quiz(
    id: _uuid.v4(), // Generate a unique ID using UUID
    title: _quizTitle,
    startDate: _startDate,
    endDate: _endDate,
    questions: _questions,
    courseId: widget.courseId,
  );

  DocumentReference docRef =
      await FirebaseFirestore.instance.collection('quizzes').add(quiz.toJson());

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => QuizDetailsScreen(quiz: quiz),
    ),
  );
}


  void _addQuestion() {
    setState(() {
      _questions.add(
        Question(
          id: _uuid.v4(), // Use UUID for unique question IDs
          text: '',
          type: 'multiple choice',
          options: ['Option 1', 'Option 2'],
          correctAnswer: '',
        ),
      );
    });
    _navigateToPage(_questions.length); // Navigate to the new question
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Quiz')),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disable swipe
          children: [
            Padding(
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
                    onDateTimeChanged: (dateTime) =>
                        setState(() => _startDate = dateTime),
                  ),
                  DatePickerField(
                    label: 'End Date & Time',
                    initialDateTime: _endDate,
                    onDateTimeChanged: (dateTime) =>
                        setState(() => _endDate = dateTime),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () => _navigateToPage(1),
                      child: const Text('Next: Add Questions'),
                    ),
                  ),
                ],
              ),
            ),
            ..._questions.map((question) {
              int index = _questions.indexOf(question);
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuestionEditor(
                            question: question,
                            onChanged: (updatedQuestion) {
                              setState(() => _questions[index] = updatedQuestion);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (index > 0)
                                ElevatedButton(
                                  onPressed: () => _navigateToPage(index),
                                  child: const Text('Previous'),
                                ),
                              ElevatedButton(
                                onPressed: () => _navigateToPage(index + 2),
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _submitQuiz,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: const Color.fromARGB(255, 148, 76, 4),
                        ),
                        child: const Text('Submit Quiz'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _addQuestion,
                  child: const Text('Add New Question'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
