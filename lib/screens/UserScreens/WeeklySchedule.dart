import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<Map<String, List<Map<String, dynamic>>>> fetchSchedule(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

  List<dynamic> enrolledCourses = userDoc['enrolled_courses'];

  if (enrolledCourses.isEmpty) {
    print('No enrolled courses.');
    return {};
  }

  List<String> courseCodes = enrolledCourses.map((course) => course['code'].toString()).toList();

  QuerySnapshot coursesSnapshot = await firestore
      .collection('Courses')
      .where('code', whereIn: courseCodes)
      .get();

  List<String> courseIds = coursesSnapshot.docs.map((doc) => doc.id).toList();

  if (courseIds.isEmpty) {
    print('No matching course IDs found.');
    return {};
  }

  QuerySnapshot assignmentsSnapshot = await firestore
      .collection('assignments')
      .where('courseId', whereIn: courseIds)
      .get();

  QuerySnapshot quizzesSnapshot = await firestore
      .collection('quizzes')
      .where('courseId', whereIn: courseIds)
      .get();

  List<Map<String, dynamic>> events = [];

  for (var assignment in assignmentsSnapshot.docs) {
    var date = assignment['createdAt'];
    DateTime deadline = date is Timestamp ? date.toDate() : DateTime.parse(date);

    events.add({
      'type': 'Assignment',
      'title': assignment['title'],
      'date': deadline,
      'notificationDate': deadline.subtract(Duration(days: 1)), 
      'courseId': assignment['courseId'],
    });
  }

  for (var quiz in quizzesSnapshot.docs) {
    var date = quiz['startDate'];
    DateTime startDate = date is Timestamp ? date.toDate() : DateTime.parse(date);

    events.add({
      'type': 'Quiz',
      'title': quiz['title'],
      'date': startDate,
      'notificationDate': startDate.subtract(Duration(days: 1)), 
      'courseId': quiz['courseId'],
    });
  }

  events.sort((a, b) => a['date'].compareTo(b['date']));

  Map<String, List<Map<String, dynamic>>> schedule = {};

  for (var event in events) {
    String day = DateFormat('EEEE').format(event['date']); 
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

  void checkNotifications(Map<String, List<Map<String, dynamic>>> schedule) {
    DateTime today = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      schedule.forEach((day, events) {
        for (var event in events) {
          DateTime notificationDate = event['notificationDate'];
          if (notificationDate.day == today.day &&
              notificationDate.month == today.month &&
              notificationDate.year == today.year) {
            // Trigger a notification (or alert)
            print("Reminder: Study for ${event['type']} - ${event['title']}!");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Reminder: Study for ${event['type']} - ${event['title']}!"),
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      });
    });
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('d MMMM').format(date); 
  }

  Color getEventColor(List<Map<String, dynamic>> tasksAtTime) {
    if (tasksAtTime.isEmpty) {
      return const Color.fromARGB(223, 255, 255, 255); 
    }

    tasksAtTime.sort((a, b) => a['date'].compareTo(b['date']));

    DateTime today = DateTime.now();
    for (var event in tasksAtTime) {
      DateTime eventDate = event['date'];
      if (eventDate.isBefore(today.add(Duration(days: 1))) && eventDate.isAfter(today.subtract(Duration(days: 1)))) {
        return const Color.fromRGBO(162, 200, 232, 1)!; 
      }
    }

    return const Color.fromARGB(255, 255, 255, 255)!;
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

            checkNotifications(schedule); 

            final daysOfWeek = [
              'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
            ];

            DateTime today = DateTime.now();
            List<DateTime> daysOfWeekDates = List.generate(7, (index) {
              return today.subtract(Duration(days: today.weekday - 1)).add(Duration(days: index));
            });

            Set<String> timeSlotsSet = Set();

            for (var day in schedule.values) {
              for (var event in day) {
                DateTime eventTime = event['date'];
                String timeSlot =
                    '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute >= 30 ? '30' : '00'}';
                timeSlotsSet.add(timeSlot);
              }
            }

            final timeSlots = timeSlotsSet.toList()..sort(); 

        
            return Center(
              child: Container(
                margin: EdgeInsets.all(16.0),  
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(width: 50, height: 50), 
                            ...List.generate(7, (index) {
                              String day = daysOfWeek[index];
                              String formattedDate = getFormattedDate(daysOfWeekDates[index]);
                              return Container(
                                width: 150,
                                height: 50,
                                color: const Color.fromARGB(255, 253, 253, 253),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      day,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                        Column(
                          children: timeSlots.map((time) {
                            return Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 100,
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  alignment: Alignment.center,
                                  child: Text(time),
                                ),
                                ...daysOfWeek.map((day) {
                                  final dayEvents = schedule[day] ?? [];
                                  final tasksAtTime = dayEvents.where((event) {
                                    DateTime eventTime = event['date'];
                                    int eventMinute = eventTime.minute;
                                    String eventTimeSlot =
                                        '${eventTime.hour.toString().padLeft(2, '0')}:${eventMinute >= 30 ? '30' : '00'}';

                                    return eventTimeSlot == time;
                                  }).toList();

                              tasksAtTime.sort((a, b) => a['date'].compareTo(b['date']));

                              return Container(
                                width: 150,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  color: getEventColor(tasksAtTime), // Get color based on events
                                ),
                                child: Column(
                                  children: tasksAtTime.map((event) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 4.0),
                                      padding: EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      child: Text(
                                        '${event['type']}: ${event['title']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 10.0),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                     ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}