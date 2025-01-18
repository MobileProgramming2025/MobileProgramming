import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/QuizTrail/QuizEditScreen.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_creation_screen.dart';
import 'package:mobileprogramming/services/quiz_service.dart';
import 'package:mobileprogramming/models/Quiz.dart';

class QuizListScreen extends StatelessWidget {
  final String courseId;

  QuizListScreen({super.key, required this.courseId});

  final QuizService _quizService = QuizService(); 

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please log in to view quizzes.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
      ),
      body: FutureBuilder<List<Quiz>>(
        future: _quizService.getQuizzesByUser(user.uid), // Fetch quizzes for the logged-in user
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No quizzes found.',
                style: TextStyle(color: Color.fromARGB(255, 10, 1, 0)),
              ),
            );
          }

          List<Quiz> quizzes = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return ListTile(
                      title: Text(quiz.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuizEditScreen(quizId: quiz.id, courseId: courseId,),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _quizService.deleteQuiz(quiz.id).then((_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Quiz deleted')),
                                );
                              }).catchError((error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error deleting quiz: $error')),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizCreationScreen(courseId: courseId),
                    ),
                  );
                },
                child: const Text('Add New Quiz'),
              ),
            ],
          );
        },
      ),
    );
  }
}
