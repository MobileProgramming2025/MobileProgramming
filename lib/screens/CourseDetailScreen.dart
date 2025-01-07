import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/QuizTrail/QuizListScreen.dart';
import 'package:mobileprogramming/screens/QuizTrail/quiz_creation_screen.dart'; 

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  //final AppUser doctor;

  const CourseDetailScreen({required super.key, required this.courseId });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
             
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (BuildContext context) {
                    return Wrap(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height /1.2 ,
                          child: QuizCreationScreen(courseId: courseId),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Create Quiz'),
              
            ),
            SizedBox(height: 20),
           TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssignmentListScreen(courseId: courseId )
                //  , doctor: doctor,),
                ),
              );
            },
            child: Text('View Assignments'),
          ),
           TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizListScreen(courseId: courseId),
      ),
    );
  },
  child: Text('Quizzes'),
),

          ],
        ),
      ),
    );
  }
}
