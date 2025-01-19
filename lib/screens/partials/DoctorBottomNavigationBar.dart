import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/doctorScreens/doctor_dashboard.dart';
import 'package:mobileprogramming/screens/doctorScreens/doctor_profile.dart';
import 'package:mobileprogramming/screens/doctorScreens/view_instructor_courses.dart';
import 'package:mobileprogramming/services/user_service.dart';

class DoctorBottomNavigationBar extends StatefulWidget {
  final User doctor;

  const DoctorBottomNavigationBar({super.key, required this.doctor});

  @override
  State<DoctorBottomNavigationBar> createState() =>
      _DoctorBottomNavigationBarState();
}

class _DoctorBottomNavigationBarState extends State<DoctorBottomNavigationBar> {
  final UserService _userService = UserService();
  int _currentIndex = 0;

  void _logout(context) async {
    _userService.logout(context);
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
       Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewInstructorCoursesScreen(doctor: widget.doctor),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDashboard(doctor: widget.doctor),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorProfile(user: widget.doctor),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 4:
        _logout(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Adapt background color based on theme
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850] // Dark mode background
            : Colors.grey[100], // Light mode background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[800]
              : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.blueAccent
              : Colors.indigo,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey
              : Colors.orange,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.house_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined), label: "Profile"),
            BottomNavigationBarItem(
                icon: Icon(Icons.exit_to_app), label: "Logout"),
          ],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
