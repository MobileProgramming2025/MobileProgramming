import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';

class NotificationScreen extends StatelessWidget {
  final String userId;
  final User user;
  

  NotificationScreen({super.key, required this.user,required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      drawer: UserDrawerScreen(user: user),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)  // Filter by student ID
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load notifications.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications.'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                onTap: () {
                  // Handle notification tap
                },
              );
            },
          );
        },
      ),
    );
  }
}
