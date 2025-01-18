import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/QuizTrail/QuizEditScreen.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/widgets/Quiz/date_picker_field.dart';
import 'package:mobileprogramming/widgets/Quiz/options_editor.dart';
import 'package:mobileprogramming/widgets/Quiz/question_editor.dart';

class QuizCreationScreen extends StatefulWidget {
  final String courseId;
  final String? quizId;

  const QuizCreationScreen({
    super.key,
    required this.courseId,
    this.quizId,
  });

  @override
  State<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final QuizService _quizService = QuizService();
  final TextEditingController _quizTitleController = TextEditingController();
  
  String _quizTitle = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final List<Question> _questions = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.quizId != null) {
      _fetchQuizData();
    }
  }

  @override
  void didUpdateWidget(covariant QuizCreationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quizId != oldWidget.quizId) {
      _fetchQuizData();
    }
  }

  Future<void> _fetchQuizData() async {
    if (widget.quizId == null) return;
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (doc.exists) {
        Quiz quiz = Quiz.fromJson(doc.data() as Map<String, dynamic>);
        setState(() {
          _quizTitle = quiz.title;
          _quizTitleController.text = _quizTitle;
          _startDate = quiz.startDate;
          _endDate = quiz.startDate.add(quiz.duration);
          _questions
            ..clear()
            ..addAll(quiz.questions);
        });
      }
    } catch (error) {
      _showError('Error loading quiz: $error');
    }
  }
void _submitQuiz() async {
  // Validate quiz title, questions, and date range
  if (_quizTitle.isEmpty) {
    _showError('Please provide a title for the quiz.');
    return;
  }

  // Validate that each question has a text and options
  for (var question in _questions) {
    if (question.text.isEmpty) {
      _showError('Please provide text for all questions.');
      return;
    }
    if (question.options!.isEmpty || question.options!.any((option) => option.isEmpty)) {
      _showError('Please provide options for all questions.');
      return;
    }
  }

  if (_questions.isEmpty) {
    _showError('Please add at least one question.');
    return;
  }

  if (_startDate.isAfter(_endDate)) {
    _showError('Start date cannot be after the end date.');
    return;
  }

  // Validate duration (it should be positive and not zero)
  Duration quizDuration = _endDate.difference(_startDate);
  if (quizDuration.inMinutes <= 0) {
    _showError('Quiz duration should be greater than zero.');
    return;
  }

  // Disable the submit button while submitting
  setState(() => _isSubmitting = true);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('User not logged in.');
      return;
    }

    final quizId = widget.quizId ?? FirebaseFirestore.instance.collection('quizzes').doc().id;
    final quiz = Quiz(
      id: quizId,
      title: _quizTitle,
      startDate: _startDate,
      duration: quizDuration,
      questions: _questions.map((q) {
        return q.id.isEmpty
            ? q.copyWith(id: FirebaseFirestore.instance.collection('quizzes/$quizId/questions').doc().id)
            : q;
      }).toList(),
      courseId: widget.courseId,
      createdBy: user.uid,
    );

    // If quiz ID is null, create a new quiz, otherwise update the existing quiz
    if (widget.quizId == null) {
      await FirebaseFirestore.instance.collection('quizzes').doc(quizId).set(quiz.toJson());
    } else {
      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update(quiz.toJson());
    }

    // Check if the widget is still mounted
    if (!mounted) return;

    // Navigate to the quiz edit screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => QuizEditScreen(quizId: quizId, courseId: widget.courseId)),
    );
  } catch (error) {
    _showError('Error saving quiz: $error');
  } finally {
    setState(() => _isSubmitting = false);
  }
}

  void _deleteQuiz() async {
    if (widget.quizId == null) return;

    try {
      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).delete();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      _showError('Error deleting quiz: $error');
    }
  }

  void _addQuestion() {
    final quizId = widget.quizId ?? FirebaseFirestore.instance.collection('quizzes').doc().id;
    final newQuestionId = FirebaseFirestore.instance
        .collection('quizzes/$quizId/questions')
        .doc()
        .id;

    setState(() {
      _questions.add(
        Question(
          id: newQuestionId,
          text: '',
          type: 'multiple choice',
          options: ['Option 1', 'Option 2'],
          correctAnswer: '',
        ),
      );
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _onWillPop() async {
    if (_quizTitle.isEmpty && _questions.isEmpty) {
      return true;
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Are you sure you want to cancel the quiz creation? All changes will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create/Edit Quiz'),
            actions: widget.quizId != null
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteQuiz,
                    ),
                  ]
                : null,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => setState(() => _quizTitle = value),
                  controller: _quizTitleController,
                  decoration: const InputDecoration(labelText: 'Quiz Title'),
                ),
                DateTimePickerField(
                  label: 'Start Date & Time',
                  initialDateTime: _startDate,
                  onDateTimeChanged: (dateTime) => setState(() => _startDate = dateTime),
                ),
                DateTimePickerField(
                  label: 'End Date & Time',
                  initialDateTime: _endDate,
                  onDateTimeChanged: (dateTime) => setState(() => _endDate = dateTime),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _addQuestion,
                    child: const Text('Add New Question'),
                  ),
                ),
                const SizedBox(height: 16),
                ..._questions.map((question) {
                  final index = _questions.indexOf(question);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        QuestionEditor(
                          question: question,
                          onChanged: (updatedQuestion) {
                            setState(() => _questions[index] = updatedQuestion);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitQuiz,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
