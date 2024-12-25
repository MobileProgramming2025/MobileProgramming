import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileprogramming/screens/AdminScreens/AddDoctorScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/DashboardScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/admin_dashboard.dart';
import 'package:mobileprogramming/screens/AdminScreens/list_users.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/Quiz/quiz_creation_screen.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((fn) {
    runApp(const MyApp());
  });

  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University LMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        hintColor: Colors.amber,
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
          bodySmall: TextStyle(fontSize: 16, color: Colors.grey[80]),
        ),
        // useMaterial3: true,
        scaffoldBackgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signin': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/admin_home': (context) => AdminDashboard(),
        '/add_users': (context) => AddUserScreen(),
        '/list_users': (context) => ListUsersScreen(),
        '/create_assignment': (context) => AssignmentListScreen(courseId: "course123"),
        '/createQuiz': (context) => QuizCreationScreen(),
        '/add-doctor': (context) => AddDoctorScreen(),
        '/Doctors Dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
