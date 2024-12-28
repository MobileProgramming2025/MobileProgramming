import 'package:flutter/material.dart';

class DoctorDrawer extends StatelessWidget {
  const DoctorDrawer({Key? key}) : super(key: key);

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
              leading: Icon(Icons.person),
              title: Text('Dashboard'),
              onTap: () {
               Navigator.pushNamed(context, '/Doctor-dashboard');
              },
            ),
             ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
               
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle logout
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
            title: Text('Create Assignment'),
            onTap: () {
              Navigator.pushNamed(context, '/create_assignment');
            },
          ),
        ],
      ),
    );
  }
}
