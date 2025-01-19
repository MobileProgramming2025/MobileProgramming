import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/UserScreens/ToDoPage.dart';
import 'package:mobileprogramming/screens/UserScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/UserScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/UserScreens/advising_screen.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/services/user_service.dart';

class UserDrawer extends StatelessWidget {
  final UserService _userService = UserService();
  final User user;

  UserDrawer({super.key, required this.user});

  void _logout(context) async {
    _userService.logout(context);
  }
  

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(
              'Hello, ${user.name}',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserHome(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_outlined),
            title: Text('My Courses'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCoursesScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_outlined),
            title: Text('My Courses'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCoursesScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.collections_bookmark_outlined),
            title: Text('Advising'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdvisingScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book_rounded),
            title: Text('View Assignments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAssignmentListScreen(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.timer_outlined),
            title: Text('Time Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToDoPage(user: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
