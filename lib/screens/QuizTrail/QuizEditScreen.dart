import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/QuizTrail/Quiz_Detail_screen.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/widgets/Quiz/date_picker_field.dart';
import 'package:mobileprogramming/widgets/Quiz/options_editor.dart';
import 'package:mobileprogramming/widgets/Quiz/question_editor.dart';

class QuizEditScreen extends StatefulWidget {
  final String quizId;
  final String courseId;

  const QuizEditScreen({super.key, required this.quizId, required this.courseId});

  @override
  State<QuizEditScreen> createState() => _QuizEditScreenState();
}

class _QuizEditScreenState extends State<QuizEditScreen> {
  final QuizService _quizService = QuizService();
  String _quizTitle = '';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final List<Question> _questions = [];
  bool _isSubmitting = false;
  bool _isLoading = true;

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (doc.exists) {
        Quiz quiz = Quiz.fromJson(doc.data() as Map<String, dynamic>);
        setState(() {
          _quizTitle = quiz.title;
          _startDate = quiz.startDate;
          _endDate = quiz.startDate.add(quiz.duration);
          _questions.clear();
          _questions.addAll(quiz.questions);  // Fetch existing questions from quiz document
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz not found!')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching quiz: $error')),
      );
    }
  }

  void _submitQuiz() async {
    if (_quizTitle.isEmpty || _questions.isEmpty || _startDate.isAfter(_endDate)) {
      _showError('Please provide a title, at least one question, and a valid date range.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError('User not logged in.');
        return;
      }

      final quiz = Quiz(
        id: widget.quizId,
        title: _quizTitle,
        startDate: _startDate,
        duration: _endDate.difference(_startDate),
        questions: _questions,  // Save questions directly inside the quiz
        courseId: widget.courseId,
        createdBy: user.uid,
      );

      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update(quiz.toJson());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz updated successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizDetailsScreen(quiz: quiz, courseId: widget.courseId)),
      );
    } catch (error) {
      _showError('Error updating quiz: $error');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _deleteQuiz() async {
    try {
      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz deleted successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      _showError('Error deleting quiz: $error');
    }
  }
void _addQuestion() async {
  final newQuestionId = FirebaseFirestore.instance.collection('quizzes').doc().id;

  // Show a dialog or navigate to a new screen to input question details
  final Question? newQuestion = await showDialog<Question>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Question'),
        content: QuestionEditor(
          // Pass an empty Question or default data to question parameter
          question: Question(
            id: newQuestionId,
            text: '', // Default empty text, to be filled later by user
            type: 'multiple choice', // Default type
            options: ['Option 1', 'Option 2'], // Default options
            correctAnswer: '', // Default empty correct answer
          ),
          onChanged: (updatedQuestion) {
            // You can update the question when the user modifies it
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null); // Return null if user cancels
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                Question(
                  id: newQuestionId,
                  text: '', // Default empty text, to be filled later by user
                  type: 'multiple choice', // Default type
                  options: ['Option 1', 'Option 2'], // Default options
                  correctAnswer: '', // Default empty correct answer
                ),
              );
            },
            child: const Text('Save Question'),
          ),
        ],
      );
    },
  );

  if (newQuestion != null) {
    setState(() {
      _questions.add(newQuestion);  // Add new question to the list
    });

    // Update the quiz with the new question
    final quiz = Quiz(
      id: widget.quizId,
      title: _quizTitle,
      startDate: _startDate,
      duration: _endDate.difference(_startDate),
      questions: _questions,  // Updated questions list
      courseId: widget.courseId,
      createdBy: FirebaseAuth.instance.currentUser!.uid,
    );

    FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update(quiz.toJson());
  }
}


  void _deleteQuestion(int index) async {
    setState(() {
      _questions.removeAt(index);
    });

    try {
      // Update the quiz with the new list of questions
      final quiz = Quiz(
        id: widget.quizId,
        title: _quizTitle,
        startDate: _startDate,
        duration: _endDate.difference(_startDate),
        questions: _questions,  // Updated questions list
        courseId: widget.courseId,
        createdBy: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update(quiz.toJson());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted successfully')),
      );
    } catch (error) {
      _showError('Error deleting question: $error');
    }
  }

  void _navigateToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Quiz')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteQuiz,
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => setState(() => _quizTitle = value),
                    decoration: const InputDecoration(labelText: 'Quiz Title'),
                    controller: TextEditingController(text: _quizTitle),
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
                  ElevatedButton(
                    onPressed: _addQuestion,
                    child: const Text('Add New Question'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitQuiz,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          ),
          ..._questions.map((question) {
            final index = _questions.indexOf(question);
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    QuestionEditor(
                      question: question,
                      onChanged: (updatedQuestion) {
                        setState(() => _questions[index] = updatedQuestion);
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => _deleteQuestion(index),
                      child: const Text('Delete Question'),
                    ),
                    ElevatedButton(
                      onPressed: _submitQuiz,
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Submit Quiz'),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateToPage(0),
                      child: const Text('Back to Edit Title & Dates'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
