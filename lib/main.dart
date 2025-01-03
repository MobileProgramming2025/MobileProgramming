import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileprogramming/screens/AdminScreens/AddDoctorScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/DashboardScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_courses_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/admin_dashboard.dart';
import 'package:mobileprogramming/screens/AdminScreens/enroll_students_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/list_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/onboarding_screen.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_screen.dart';

import 'package:flutter_sizer/flutter_sizer.dart';

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
    var darkColorScheme = ColorScheme.fromSeed(
      //optimize our color scheme to shades for dark mode
      brightness: Brightness.dark,
      seedColor: const Color.fromARGB(255, 228, 151, 78),
    );

    var colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 248, 128, 18),
    );

    return FlutterSizer(builder: (context, orientation, device) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,

        //Light Mode Theme
        theme: ThemeData.light().copyWith(
          colorScheme: colorScheme,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: colorScheme.onPrimaryFixed,
            foregroundColor: colorScheme.onSecondary,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(

              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 10,
              ),
              // textStyle: TextStyle(
              //   fontSize: 15,
              //   //fontWeight: FontWeight.bold,
              // ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),

          //Drawer Theme
          drawerTheme: DrawerThemeData(
            elevation: 10,
          ),

          //Text Style
          textTheme: TextTheme(
            bodyLarge: TextStyle(
              color: colorScheme.onPrimaryContainer,
            ),
            headlineLarge: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),

          //Text Input Field
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.onPrimaryContainer,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.onPrimaryContainer,
                width: 2.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.onPrimaryContainer,
                width: 1.5,
              ),
            ),
            hintStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
            ),
            labelStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        //Dark Theme Mode
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: darkColorScheme,
        ),

        initialRoute: '/',
        routes: {
          '/': (context) => OnboardingScreen(),
          '/login': (context) => LoginScreen(),
          '/signin': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/user_home': (context) => UserHome(),
          '/admin_home': (context) => AdminDashboard(),
          '/add_users': (context) => AddUserScreen(),
          '/list_users': (context) => ListUsersScreen(),
          '/create_assignment-static': (context) => AssignmentListScreen(courseId: "course123"),
          '/assignment_screen': (context) => AssignmentScreen(),
          // '/createQuiz': (context) => CourseListPage(),
          '/add-doctor': (context) => AddDoctorScreen(),
          '/Doctors Dashboard': (context) => DashboardScreen(),
          '/add_courses': (context) => AddCoursesScreen(),
          '/view_courses': (context) => ViewCoursesScreen(),
        // '/create-assignment': (context) => CourseListPage(),
          '/enroll_students': (context) => EnrollStudentsScreen(),
        //  '/list-assignments-for-dr' : (context) => CourseListPage(),
        '/student-assignment-list': (context) => StudentAssignmentListScreen()
        },
      );
    });
  }
}
