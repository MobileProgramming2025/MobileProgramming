import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:mobileprogramming/introduction_animation_screen.dart';

import 'package:mobileprogramming/screens/AdminScreens/AddDoctorScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/Add_department_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/DashboardScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_courses_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/enroll_instructor_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/list_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_department_courses.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_departments_screen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/CourseDetailScreen.dart';
import 'package:mobileprogramming/screens/Registration/google_signup_screen.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_screen.dart';
import 'package:mobileprogramming/screens/doctorScreens/view_instructor_courses.dart';

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

void main() async {
  runApp(const ProviderScope(child: MyApp()));
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define dark color scheme optimized for dark mode
    var darkColorScheme = ColorScheme(
      //optimize our color scheme to shades for dark mode
      brightness: Brightness.dark,
      primary: Colors.indigo[300]!,
      onPrimary: Colors.black,
      primaryContainer: Colors.indigo[700]!,
      onPrimaryContainer: Colors.white,
      secondary: Colors.teal[300]!,
      onSecondary: Colors.black,
      secondaryContainer: Colors.teal[700]!,
      onSecondaryContainer: Colors.white,
      tertiary: Colors.orange[300]!,
      onTertiary: Colors.black,
      tertiaryContainer: Colors.orange[700]!,
      onTertiaryContainer: Colors.white,
      surface: const Color.fromARGB(255, 40, 40, 40),
      onSurface: Colors.white,
      error: Colors.red[300]!,
      onError: Colors.black,
    );

    var colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.indigo,
      onPrimary: Colors.white,
      primaryContainer: Colors.indigo[100]!,
      onPrimaryContainer: Colors.indigo[800]!,
      secondary: Colors.teal,
      onSecondary: Colors.white,
      secondaryContainer: Colors.teal[100]!,
      onSecondaryContainer: Colors.orange,
      tertiary: Colors.orange,
      onTertiary: const Color.fromARGB(255, 70, 70, 70),
      tertiaryContainer: Colors.orange[100]!,
      onTertiaryContainer: Colors.orange[800]!,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    );

    return FlutterSizer(builder: (context, orientation, device) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,

        //Light Mode Theme
        theme: ThemeData.light().copyWith(
          colorScheme: colorScheme,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: colorScheme.onPrimaryContainer,
            foregroundColor: colorScheme.onPrimary,
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
            bodyMedium: TextStyle(
              color: colorScheme.onTertiary,
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
          '/': (context) => IntroductionAnimationScreen(),
          '/login': (context) => LoginScreen(),
          '/signin': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/add_users': (context) => AddUserScreen(),
          '/list_users': (context) => ListUsersScreen(),
          '/create_assignment-static': (context) =>
              AssignmentListScreen(courseId: "course123"),
          '/assignment_screen': (context) => AssignmentScreen(),
          //  '/createQuiz': (context) => CourseListPage(),
          '/add-doctor': (context) => AddDoctorScreen(),
          '/Doctors Dashboard': (context) => DashboardScreen(),
          '/add_courses': (context) => AddCoursesScreen(),
          '/view_courses': (context) => ViewCoursesScreen(),
          // '/create-assignment': (context) => CourseListPage(),
          // '/enroll_students': (context) => EnrollStudentsScreen(),
          //  '/list-assignments-for-dr' : (context) => CourseListPage(),
          '/student-assignment-list': (context) =>
              StudentAssignmentListScreen(),
          '/add_department': (context) => AddDepartmentScreen(),
          '/view_departments': (context) => ViewDepartmentsScreen(),
          '/view_department_courses': (context) =>
              ViewDepartmentCoursesScreen(),
          '/enroll_instructor': (context) => EnrollInstructorScreen(),
          '/view_Instructor_courses': (context) =>
              ViewInstructorCoursesScreen(),
          '/view_courses_details': (context) => CourseDetailScreen(),
          '/google_sign_up': (context) => GoogleSignUpScreen(),
        },
      );
    });
  }
}
