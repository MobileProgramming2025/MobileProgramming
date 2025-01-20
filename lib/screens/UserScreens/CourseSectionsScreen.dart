import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_attempt_screen.dart';
import 'package:mobileprogramming/models/user.dart';

import 'package:mobileprogramming/services/quiz_service.dart'; // Assuming you have a service to fetch quizzes

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String userId;
  final User user;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.userId,
    required this.user,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  late Quiz quiz; // Declare the quiz variable
  bool isLoading = true; // To show a loading indicator while fetching quiz data
  bool isQuizAvailable = false; // Flag to track if quiz is available

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  // Method to fetch the quiz data
  void _fetchQuizData() async {
    try {
      List<Quiz> fetchedQuizzes = await QuizService().fetchQuizzesByCourseId(widget.courseId);

      if (fetchedQuizzes.isNotEmpty) {
        setState(() {
          quiz = fetchedQuizzes.first;
          isQuizAvailable = true; // Mark quiz as available
          isLoading = false; // Hide the loading indicator
        });
      } else {
        setState(() {
          isLoading = false; // Hide loading indicator if no quiz is found
          isQuizAvailable = false; // Mark quiz as unavailable
        });
        print("No quizzes found for this course.");
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Hide loading indicator in case of an error
      });
      print("Error fetching quiz: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Details Section
                  Text(
                    'Course Name: ${widget.courseName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Course Code: ${widget.courseCode}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Divider(height: 30, thickness: 1.5),

                  // Action Buttons Section
                  Expanded(
                    child: ListView(
                      children: [
                        // Quiz Button
                        ElevatedButton.icon(
                          onPressed: () {
                            if (!isQuizAvailable) {
                              // Show an alert dialog if there is no quiz
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('No Quiz Available'),
                                    content: const Text(
                                        'There is no quiz available for this course.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); 
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttemptQuizScreen(
                                    courseId: widget.courseId,
                                    userId: widget.userId,
                                    quiz: quiz,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.quiz),
                          label: const Text('Take Quiz'),
                        ),

                        const SizedBox(height: 10),

                        // Assignments Button
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentAssignmentListScreen(user: widget.user),
                              ),
                            );
                          },
                          icon: const Icon(Icons.assignment),
                          label: const Text('View Assignments'),
                        ),
                        const SizedBox(height: 10),

                        // UI Assignment Details (Optional)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentAssignmentListScreen(user: widget.user),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('UI Assignment Details'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
