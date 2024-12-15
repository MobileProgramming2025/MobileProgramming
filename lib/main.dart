import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/admin_home.dart';
import 'package:mobileprogramming/screens/user_home.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University LMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/admin_home': (context) => AdminHomeScreen(),
        '/signin': (context) => LoginScreen(),
      },
    );
  }
}
