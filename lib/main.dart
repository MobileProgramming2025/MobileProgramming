import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/Assignment/CreateAssignmentScreen.dart';
import 'package:mobileprogramming/screens/Assignment/AssignmentListScreen.dart';
import 'package:mobileprogramming/screens/Assignment/SubmitAssignmentScreen.dart';



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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      
      routes: {
        '/': (context) => const HomeScreen(), 
        '/create-assignment': (context) =>  const CreateAssignmentScreen(),
        '/assignments': (context) =>  AssignmentListScreen(),
       
      },
     
      initialRoute: '/',
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University LMS Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-assignment');
              },
              child: const Text('Create Assignment'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/assignments');
              },
              child: const Text('View Assignments'),
            ),
            ElevatedButton(
              onPressed: () {
                // Example of passing arguments to a route
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubmitAssignmentScreen(
                      assignmentId: 'sampleAssignmentId',
                      studentId: 'sampleStudentId',
                    ),
                  ),
                );
              },
              child: const Text('Submit Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
