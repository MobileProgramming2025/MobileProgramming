import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/Assignment/CreateAssignmentScreen.dart';
import 'package:mobileprogramming/screens/Quiz/quiz_creation_screen.dart'; 

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  CourseDetailScreen({required this.courseId});

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
            ElevatedButton(
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateAssignmentScreen(),
                  ),
                );
              },
              child: Text('Create Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
