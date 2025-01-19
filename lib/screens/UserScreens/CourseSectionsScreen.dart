import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Quiz.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_attempt_screen.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';

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

  @override
  void initState() {
    super.initState();
    // Fetch the quiz dynamically using the courseId or any other relevant information
    _fetchQuizData();
  }

  // Method to fetch the quiz data
  void _fetchQuizData() async {
    try {
      // Assuming you have a QuizService that fetches quizzes based on courseId
      List<Quiz> fetchedQuizzes = await QuizService().fetchQuizzesByCourseId(widget.courseId);

      if (fetchedQuizzes.isNotEmpty) {
        setState(() {
          quiz = fetchedQuizzes.first; // Assuming you're taking the first quiz from the list
          isLoading = false;  // Hide the loading indicator
        });
      } else {
        setState(() {
          isLoading = false;  // Hide loading indicator if no quiz is found
        });
        // Handle error or show message to the user if no quiz found
        print("No quizzes found for this course.");
      }
    } catch (error) {
      setState(() {
        isLoading = false;  // Hide loading indicator in case of an error
      });
      // Handle error (e.g., show a message to the user)
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
      drawer:UserDrawer(user: widget.user),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AttemptQuizScreen(
                                  courseId: widget.courseId,
                                  userId: widget.userId,
                                  quiz: quiz, // Pass the dynamically fetched Quiz object
                                ),
                              ),
                            );
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
