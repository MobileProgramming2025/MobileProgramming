import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';
import 'package:mobileprogramming/services/quiz_service.dart';


class QuizAttemptScreen extends StatefulWidget {
  final String quizId;

  QuizAttemptScreen({required this.quizId});

  @override
  _QuizAttemptScreenState createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  final QuizService _quizService = QuizService();
  List<Question> _questions = [];
  List<String> _studentAnswers = [];

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  void _loadQuiz() async {
    _questions = await _quizService.getQuestions(widget.quizId);
    setState(() {});
  }

  void _submitQuiz() {
    // Logic to save answers and calculate score
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attempt Quiz')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_questions[index].text),
                    if (_questions[index].options != null)
                      Column(
                        children: _questions[index].options!.map((opt) {
                          return RadioListTile<String>(
                            title: Text(opt),
                            value: opt,
                            groupValue: _studentAnswers[index],
                            onChanged: (value) {
                              setState(() {
                                _studentAnswers[index] = value!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    if (_questions[index].type == 'short answer')
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _studentAnswers[index] = value;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Answer'),
                      ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _submitQuiz,
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
