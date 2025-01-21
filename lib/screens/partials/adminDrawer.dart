import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AdminScreens/Add_department_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/DashboardScreen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_courses_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/add_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/admin_dashboard.dart';
import 'package:mobileprogramming/screens/AdminScreens/list_users.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/AdminScreens/view_departments_screen.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/services/user_service.dart';

class AdminDrawer extends StatelessWidget {
  final User user;
  final UserService _userService = UserService();

  void _logout(context) async {
    _userService.logout(context);
  }

  AdminDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
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
                  builder: (context) => AdminDashboard(admin: user),
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
            leading: Icon(Icons.group_add_outlined),
            title: Text('Add Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddUserScreen(admin: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_add),
            title: Text('Add Courses'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCoursesScreen(admin: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add_rounded),
            title: Text('Add Department'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDepartmentScreen(admin: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.groups_2_sharp),
            title: Text('List Users'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListUsersScreen(admin: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book_rounded),
            title: Text('View Courses'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCoursesScreen(admin: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.book_outlined),
            title: Text('View Departments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewDepartmentsScreen(admin: user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
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
