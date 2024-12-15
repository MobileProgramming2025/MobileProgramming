import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/Assignment/CreateAssignmentScreen.dart';
import 'package:mobileprogramming/screens/Assignment/StudentViewAssignmentsScreen.dart';
import 'package:mobileprogramming/screens/Assignment/EditSubmissionScreen.dart';
import 'package:mobileprogramming/screens/Assignment/TeacherViewSubmissionsScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_list_screen.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University LMS',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AssignmentListScreen(courseId: 'course_12345')
    );
  }
}
