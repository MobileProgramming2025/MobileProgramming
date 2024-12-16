import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/services/quiz_service.dart';

class QuizCreationScreen extends StatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  _QuizCreationScreenState createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends State<QuizCreationScreen> {
  final QuizService _quizService = QuizService();

  String _quizTitle = '';
  final List<Question> _questions = [];
  int _quizDuration = 0; 

  void _addQuestion() {
    setState(() {
      _questions.add(Question(
        id: DateTime.now().toString(),
        text: '',
        type: 'multiple choice',
        options: ['Option 1', 'Option 2'],
        correctAnswer: '',
      ));
    });
  }

  void _submitQuiz() async {
    if (_quizTitle.isEmpty || _questions.isEmpty || _quizDuration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please provide a title, at least one question, and a valid duration.'),
      ));
      return;
    }

    String quizId = DateTime.now().toString();
    Quiz quiz = Quiz(
      id: quizId,
      title: _quizTitle,
      questions: _questions,
      duration: _quizDuration, courseId: 'tryid', 
    );
    await _quizService.createQuiz(quiz);

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
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _quizDuration = int.tryParse(value) ?? 0;
                });
              },
              decoration: const InputDecoration(labelText: 'Quiz Duration (in seconds)'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _questions[index].text = value;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Question ${index + 1}'),
                      ),
                      DropdownButtonFormField<String>(
                        value: _questions[index].type,
                        items: const [
                          DropdownMenuItem(value: 'multiple choice', child: Text('Multiple Choice')),
                          DropdownMenuItem(value: 'short answer', child: Text('Short Answer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _questions[index].type = value!;
                            if (value == 'short answer') {
                              _questions[index].options = [];
                              _questions[index].correctAnswer = '';
                            } else if (_questions[index].options == null || _questions[index].options!.isEmpty) {
                              _questions[index].options = ['Option 1', 'Option 2'];
                              _questions[index].correctAnswer = '';
                            }
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Question Type'),
                      ),
                      if (_questions[index].type == 'multiple choice' && _questions[index].options != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Options:'),
                            ..._questions[index].options!.map((opt) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {
                                        int optionIndex = _questions[index].options!.indexOf(opt);
                                        setState(() {
                                          _questions[index].options![optionIndex] = value;
                                        });
                                      },
                                      decoration: const InputDecoration(labelText: 'Option'),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _questions[index].options!.remove(opt);
                                      });
                                    },
                                  ),
                                ],
                              );
                            }),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _questions[index].options!.add('');
                                });
                              },
                              child: const Text('Add Option'),
                            ),
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  _questions[index].correctAnswer = value;
                                });
                              },
                              decoration: const InputDecoration(labelText: 'Correct Answer'),
                            ),
                          ],
                        ),
                      if (_questions[index].type == 'short answer')
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _questions[index].correctAnswer = value;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Correct Answer'),
                        ),
                    ],
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
              child: const Text('Submit Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
