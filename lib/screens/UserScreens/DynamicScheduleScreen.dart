import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/screens/UserScreens/AddSchedule.dart';

class DynamicScheduleScreen extends StatelessWidget {
  final String userId;

  DynamicScheduleScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Schedule'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('schedules')
            .where('userId', isEqualTo: userId)
            .orderBy('startTime')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final schedules = snapshot.data!.docs;

          if (schedules.isEmpty) {
            return Center(child: Text('No scheduled events found.'));
          }

          return ListView.builder(
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return Card(
                child: ListTile(
                  title: Text(schedule['title']),
                  subtitle: Text(
                    '${schedule['startTime'].toDate()} - ${schedule['endTime'].toDate()}',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('schedules')
                          .doc(schedule.id)
                          .delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddScheduleScreen(userId: userId),
            ),
          );
        },
      ),
    );
  }
}
