import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/UserScreens/DynamicScheduleScreen.dart';
import 'package:mobileprogramming/screens/UserScreens/view_courses_screen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_assignment_list.dart';
import 'package:mobileprogramming/screens/UserScreens/ToDoPage.dart';
import 'package:mobileprogramming/screens/UserScreens/advising_screen.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/screens/UserScreens/notifications_screen.dart'; // New screen for notifications
import 'package:mobileprogramming/services/user_service.dart';
import 'package:mobileprogramming/screens/UserScreens/WeeklySchedule.dart';

class UserDrawerScreen extends StatefulWidget {
  final User user;

  UserDrawerScreen({super.key, required this.user});

  @override
  State<UserDrawerScreen> createState() => _UserDrawerScreenState();
}

class _UserDrawerScreenState extends State<UserDrawerScreen> {
  final UserService _userService = UserService();
  bool _hasNewNotifications = false;
  late StreamSubscription _notificationsSubscription;

  @override
  void initState() {
    super.initState();
    _listenForNewNotifications();
  }

  @override
  void dispose() {
    _notificationsSubscription.cancel();
    super.dispose();
  }

  void _listenForNewNotifications() {
    final userId = widget.user.id;
    _notificationsSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId) // Filter by user ID
        .where('createdAt',
            isGreaterThan: Timestamp.fromMillisecondsSinceEpoch(
                0)) // To ensure we get all notifications initially
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _hasNewNotifications = true;
        });
      }
    });
  }

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
              'Hello, ${widget.user.name}',
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
                  builder: (context) => UserHome(user: widget.user),
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
                  builder: (context) => ViewCoursesScreen(user: widget.user),
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
                  builder: (context) => AdvisingScreen(user: widget.user),
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
                  builder: (context) => ProfileScreen(user: widget.user),
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
                  builder: (context) =>
                      StudentAssignmentListScreen(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt_rounded),
            title: Text('To-Do List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ToDoPage(user: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Weekly Schedule'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WeeklySchedule(user: widget.user,userId: widget.user.id),
                ),
              );
            },
          ),
          ListTile(
            leading: Stack(
              children: [
                Icon(Icons.notifications),
                if (_hasNewNotifications)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 5,
                    ),
                  ),
              ],
            ),
            title: Text('Notifications'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationScreen(user:widget.user,userId: widget.user.id),
                ),
              );
              setState(() {
                _hasNewNotifications = false;
              });
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
