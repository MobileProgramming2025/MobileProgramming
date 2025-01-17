import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/Quiz/QuizDetailsScreen.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/widgets/Quiz/date_picker_field.dart';
import 'package:mobileprogramming/widgets/Quiz/options_editor.dart';

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
  final PageController _pageController = PageController();

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
    try {
      if (widget.quizId == null) return;

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (doc.exists) {
        Quiz quiz = Quiz.fromJson(doc.data() as Map<String, dynamic>);
        setState(() {
          _quizTitle = quiz.title;
          _startDate = quiz.startDate;
          _endDate = quiz.endDate;
          _questions.addAll(quiz.questions);
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading quiz: $error')),
      );
    }
  }

  void _submitQuiz() async {
    if (_quizTitle.isEmpty || _questions.isEmpty || _startDate.isAfter(_endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title, at least one question, and a valid date range.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      String quizId = widget.quizId ?? FirebaseFirestore.instance.collection('quizzes').doc().id;

      Quiz quiz = Quiz(
        id: quizId,
        title: _quizTitle,
        startDate: _startDate,
        endDate: _endDate,
        questions: _questions.map((q) {
          return q.id.isEmpty
              ? q.copyWith(id: FirebaseFirestore.instance.collection('quizzes/$quizId/questions').doc().id)
              : q;
        }).toList(),
        courseId: widget.courseId,
        createdBy: user.uid,
      );

      if (widget.quizId == null) {
        await FirebaseFirestore.instance.collection('quizzes').doc(quizId).set(quiz.toJson());
      } else {
        await FirebaseFirestore.instance.collection('quizzes').doc(widget.quizId).update(quiz.toJson());
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => QuizDetailsScreen(quiz: quiz)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving quiz: $error')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting quiz: $error')),
      );
    }
  }

void _addQuestion() {
  String quizId = widget.quizId ?? FirebaseFirestore.instance.collection('quizzes').doc().id;

  String newQuestionId = FirebaseFirestore.instance
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
  _navigateToPage(_questions.length);
}


  void _navigateToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
            actions: <Widget>[
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
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      children: [
                        QuestionEditor(
                          question: question,
                          onChanged: (updatedQuestion) {
                            setState(() => _questions[index] = updatedQuestion);
                          },
                        ),
                        ElevatedButton(
                          onPressed: _submitQuiz,
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
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
      ),
    );
  }
}
