import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:mobileprogramming/screens/AssignmentScreens/ui-assignment-details.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_screen.dart';

import 'package:flutter_sizer/flutter_sizer.dart';
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
  // WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight])
  // .then((fn) {
  runApp(const MyApp());
  // });

  await Firebase.initializeApp();
  // await Future.delayed(Duration(seconds: 2)); // Add a small delay

  // Enable App Check
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.playIntegrity,
  // );
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
          '/': (context) => IntroductionAnimationScreen(),
          '/login': (context) => LoginScreen(),
          '/signin': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/add_users': (context) => AddUserScreen(),
          '/list_users': (context) => ListUsersScreen(),
          '/create_assignment-static': (context) =>
              AssignmentListScreen(courseId: "course123"),
          '/assignment_screen': (context) => AssignmentScreen(),
          // '/createQuiz': (context) => CourseListPage(),
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
          '/view_departments':(context) => ViewDepartmentsScreen(),
          '/view_department_courses':(context) => ViewDepartmentCoursesScreen(),
          '/enroll_instructor':(context) => EnrollInstructorScreen(),
          '/view_Instructor_courses':(context) => ViewInstructorCoursesScreen(),


        },
      );
    });
  }
}
