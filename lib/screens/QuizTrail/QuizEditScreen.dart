import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/Quiz/QuizDetailsScreen.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/widgets/Quiz/date_picker_field.dart';
import 'package:mobileprogramming/widgets/Quiz/options_editor.dart';

class QuizEditScreen extends StatefulWidget {
  final String quizId;

  const QuizEditScreen({super.key, required this.quizId});

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
          _questions.addAll(quiz.questions);
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
        questions: _questions.map((q) {
          return q.id.isEmpty
              ? q.copyWith(id: FirebaseFirestore.instance.collection('quizzes/$widget.quizId/questions').doc().id)
              : q;
        }).toList(),
        courseId: 'some_course_id',  // replace with actual courseId
        createdBy: user.uid,
      );

      await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update(quiz.toJson());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz updated successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizDetailsScreen(quiz: quiz)),
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

  void _addQuestion() {
    final newQuestionId = FirebaseFirestore.instance
        .collection('quizzes/$widget.quizId/questions')
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

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
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
      body: Padding(
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
              child: const Text('Add Question'),
            ),
            const SizedBox(height: 24),
            ..._questions.map((question) {
              final index = _questions.indexOf(question);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) => setState(() {
                        question.text = value;
                      }),
                      decoration: const InputDecoration(labelText: 'Question'),
                    ),
                    ...question.options!.map((option) {
                      int optionIndex = question.options!.indexOf(option);
                      return TextField(
                        onChanged: (value) {
                          setState(() {
                            question.options![optionIndex] = value;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Option ${optionIndex + 1}'),
                      );
                    }).toList(),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          question.correctAnswer = value;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Correct Answer'),
                    ),
                    ElevatedButton(
                      onPressed: () => _removeQuestion(index),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Remove Question'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitQuiz,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
