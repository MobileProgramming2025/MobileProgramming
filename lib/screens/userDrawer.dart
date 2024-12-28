import 'package:flutter/material.dart';

class UserDrawer extends StatelessWidget {
  const UserDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/user_home');
            },
          ),
          ListTile(
            leading: Icon(Icons.group_add_outlined),
            title: Text('View Courses'),
            onTap: () {
              Navigator.pushNamed(context, '/view_course');
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_add),
            title: Text('View Assignments'),
            onTap: () {
              Navigator.pushNamed(context, '/assignment_screen');
            },
          ),
        ],
      ),
    );
  }
}
