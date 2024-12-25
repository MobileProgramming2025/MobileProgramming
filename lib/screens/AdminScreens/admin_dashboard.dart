import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget{
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
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
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
              leading: Icon(Icons.add),
              title: Text('Add users'),
              onTap: () {
                Navigator.pushNamed(context, '/add_users');
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Swipe from the left or tap the menu icon to open the drawer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16
          ),
        ),
      ),
    );
  }
}