import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/UserScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/services/user_service.dart';

class UserBottomNavigationBar extends StatefulWidget {
  final User user;

  const UserBottomNavigationBar({super.key, required this.user});

  @override
  State<UserBottomNavigationBar> createState() =>
      _UserBottomNavigationBarState();
}

class _UserBottomNavigationBarState extends State<UserBottomNavigationBar> {
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
            builder: (context) => ViewCoursesScreen(user: widget.user),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserHome(user: widget.user),
          ),
        );
        (Route<dynamic> route) => false;
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(user: widget.user),
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
