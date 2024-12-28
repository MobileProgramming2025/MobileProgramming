import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.group_add_outlined),
              title: Text('Add Users'),
              onTap: () {
                Navigator.pushNamed(context, '/add_users');
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_add),
              title: Text('Add Courses'),
              onTap: () {
                Navigator.pushNamed(context, '/add_courses');
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('List Users'),
              onTap: () {
                Navigator.pushNamed(context, '/list_users');
              },
            ),
            ListTile(
              leading: Icon(Icons.menu_book_rounded),
              title: Text('View Courses'),
              onTap: () {
                Navigator.pushNamed(context, '/view_courses');
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Doctors Dashboard'),
              onTap: () {
                Navigator.pushNamed(context, '/Doctors Dashboard');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Swipe from the left or tap the menu icon to open the drawer.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
