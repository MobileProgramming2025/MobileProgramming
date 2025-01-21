import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

import 'package:mobileprogramming/introduction_animation_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/AddDoctorScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/enroll_instructor_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_department_courses.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/assignment_list_screen.dart';
import 'package:mobileprogramming/screens/doctorScreens/CourseDetailScreen.dart';
import 'package:mobileprogramming/screens/Registration/google_signup_screen.dart';
import 'package:mobileprogramming/screens/Registration/signin.dart';
import 'package:mobileprogramming/screens/Registration/signup.dart';
import 'package:mobileprogramming/screens/Assignment/assignment_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("Error loading .env file: $e");
  }
  await Firebase.initializeApp();

  await Supabase.initialize(
    url: 'https://cspuiyyiuyyoihscmodk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzcHVpeXlpdXl5b2loc2Ntb2RrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcyODU0MTYsImV4cCI6MjA1Mjg2MTQxNn0.4B8eKp1tFTGY7A6K6zhlImaaTjE2YjHgbn-6erEz4A0',
  );

  runApp(const ProviderScope(child: MyApp()));
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
      secondary: const Color.fromARGB(255, 162, 172, 231),
      onSecondary: Colors.white,
      secondaryContainer: Colors.teal,
      onSecondaryContainer: Colors.orange,
      tertiary: Colors.orange,
      onTertiary: const Color.fromARGB(255, 46, 46, 46),
      tertiaryContainer: const Color.fromARGB(255, 245, 241, 236),
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

          scaffoldBackgroundColor: colorScheme.tertiaryContainer,

          //elevated button
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              textStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          //Floating action button Theme
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),

          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),

          //Drawer Theme
          drawerTheme: DrawerThemeData(
            elevation: 10,
          ),

        //SnackBar
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color.fromARGB(255, 46, 46, 46),
            actionTextColor: Colors.black,
            
          ),
          //Text Style
          textTheme: TextTheme(
            bodyLarge: TextStyle(
              color: colorScheme.onSurface,
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
            titleMedium: TextStyle(
              color: colorScheme.onSurface,
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
              color: colorScheme.onSurface,
            ),
            labelStyle: TextStyle(
              color: colorScheme.onSurface,
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
          '/signup': (context) => SignUpScreen(),
          '/google_sign_up': (context) => GoogleSignUpScreen(),
          '/create_assignment-static': (context) =>
              AssignmentListScreen(courseId: "course123"),
          '/assignment_screen': (context) => AssignmentScreen(),
          '/add-doctor': (context) => AddDoctorScreen(),
          '/view_department_courses': (context) =>
              ViewDepartmentCoursesScreen(),
          '/enroll_instructor': (context) => EnrollInstructorScreen(),
          '/view_courses_details': (context) => CourseDetailScreen(),
        },
      );
    });
  }
}
