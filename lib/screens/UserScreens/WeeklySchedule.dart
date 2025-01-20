import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; 
Future<Map<String, List<Map<String, dynamic>>>> fetchSchedule(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Step 1: Fetch user document
  DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

  // Extract enrolled courses
  List<dynamic> enrolledCourses = userDoc['enrolled_courses'];

  if (enrolledCourses.isEmpty) {
    print('No enrolled courses.');
    return {};
  }

  // Extract course codes
  List<String> courseCodes = enrolledCourses.map((course) => course['code'].toString()).toList();

  // Step 2: Fetch course documents to get course IDs
  QuerySnapshot coursesSnapshot = await firestore.collection('Courses')
      .where('code', whereIn: courseCodes)
      .get();

  List<String> courseIds = coursesSnapshot.docs.map((doc) => doc.id).toList();

  if (courseIds.isEmpty) {
    print('No matching course IDs found.');
    return {};
  }

  // Step 3: Fetch assignments and quizzes using course IDs
  QuerySnapshot assignmentsSnapshot = await firestore.collection('assignments')
      .where('courseId', whereIn: courseIds)
      .get();

  QuerySnapshot quizzesSnapshot = await firestore.collection('quizzes')
      .where('courseId', whereIn: courseIds)
      .get();

  // Combine assignments and quizzes
  List<Map<String, dynamic>> events = [];

  for (var assignment in assignmentsSnapshot.docs) {
    var date = assignment['createdAt'];
    events.add({
      'type': 'Assignment',
      'title': assignment['title'],
      'date': date is Timestamp ? date.toDate() : DateTime.parse(date),
      'courseId': assignment['courseId']
    });
  }

  for (var quiz in quizzesSnapshot.docs) {
    var date = quiz['startDate'];
    events.add({
      'type': 'Quiz',
      'title': quiz['title'],
      'date': date is Timestamp ? date.toDate() : DateTime.parse(date),
      'courseId': quiz['courseId']
    });
  }

  // Sort events by date
  events.sort((a, b) => a['date'].compareTo(b['date']));

  // Group events by day of the week
  Map<String, List<Map<String, dynamic>>> schedule = {};

  for (var event in events) {
    String day = event['date'].toString().split(' ')[0];
    if (!schedule.containsKey(day)) {
      schedule[day] = [];
    }
    schedule[day]!.add(event);
  }

  return schedule;
}


class WeeklySchedule extends StatefulWidget {
  final String userId;

  WeeklySchedule({required this.userId});

  @override
  _WeeklyScheduleState createState() => _WeeklyScheduleState();
}

class _WeeklyScheduleState extends State<WeeklySchedule> {
  late Future<Map<String, List<Map<String, dynamic>>>> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = fetchSchedule(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Schedule')),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _schedule,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found'));
          } else {
            final schedule = snapshot.data!;
            return ListView(
              children: schedule.keys.map((day) {
                return ExpansionTile(
                  title: Text(day),
                  children: schedule[day]!.map((event) {
                    return ListTile(
                      title: Text('${event['type']}: ${event['title']}'),
                      subtitle: Text('Date: ${event['date']}'),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}