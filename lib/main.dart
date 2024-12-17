import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // استيراد مكتبة الخدمات
import 'package:mobileprogramming/screens/Assignment/CreateAssignmentScreen.dart';
import 'package:mobileprogramming/screens/Assignment/StudentViewAssignmentsScreen.dart';
import 'package:mobileprogramming/screens/Assignment/EditSubmissionScreen.dart';
import 'package:mobileprogramming/screens/Assignment/TeacherViewSubmissionsScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/admin_home.dart';
import 'package:mobileprogramming/screens/Assignment/student_assignments_screen.dart';
import 'package:mobileprogramming/screens/Quiz/quiz_creation_screen.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]).then((fn) {
    runApp(const MyApp());
  });

  await Firebase.initializeApp();
  
}

class MyApp extends StatelessWidget {
  @override
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University LMS',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: Colors.amber,
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
          bodySmall: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/signin': (context) => LoginScreen(),
        'create_assignment': (context) =>
            AssignmentListScreen(courseId: "course123"),
        '/createQuiz': (context) => QuizCreationScreen(),
      },
    );
  }
}
