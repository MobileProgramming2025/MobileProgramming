import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/CourseList.dart';
import 'package:mobileprogramming/screens/UserScreens/profile.dart';

class DoctorDrawer extends StatefulWidget {
  final User user;
 
  const DoctorDrawer({super.key, required this.user});

  @override
  State<DoctorDrawer> createState() => _DoctorDrawerState();
}

class _DoctorDrawerState extends State<DoctorDrawer> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user),
                  )
                );
              }
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
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CourseListPage(),
                  )
                );
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_add),
            title: Text('Create Assignment'),
            onTap: () {
              Navigator.pushNamed(context, '/create-assignment');
            },
          ),
          ListTile(
            leading: Icon(Icons.assignment_add),
            title: Text('Create Quiz'),
            onTap: () {
              Navigator.pushNamed(context, '/createQuiz');
            },
          ),
        ],
      ),
    );
  }
}
