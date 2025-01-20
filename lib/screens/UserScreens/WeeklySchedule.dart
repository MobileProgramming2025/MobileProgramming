import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Fetches the schedule of events for a user
Future<Map<String, List<Map<String, dynamic>>>> fetchSchedule(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch user document
  DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();

  // Get enrolled courses for the user
  List<dynamic> enrolledCourses = userDoc['enrolled_courses'];

  if (enrolledCourses.isEmpty) {
    print('No enrolled courses.');
    return {};
  }

  // Get course codes and match them with course documents
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

  // Fetch assignments and quizzes for the matching courses
  QuerySnapshot assignmentsSnapshot = await firestore
      .collection('assignments')
      .where('courseId', whereIn: courseIds)
      .get();

  QuerySnapshot quizzesSnapshot = await firestore
      .collection('quizzes')
      .where('courseId', whereIn: courseIds)
      .get();

  // List to store all events (assignments, quizzes)
  List<Map<String, dynamic>> events = [];

  // Adding assignments to the events list
  for (var assignment in assignmentsSnapshot.docs) {
    var date = assignment['createdAt'];
    DateTime deadline = date is Timestamp ? date.toDate() : DateTime.parse(date);

    events.add({
      'type': 'Assignment',
      'title': assignment['title'],
      'date': deadline,
      'notificationDate': deadline.subtract(Duration(days: 1)), // Notification date
      'courseId': assignment['courseId'],
    });
  }

  // Adding quizzes to the events list
  for (var quiz in quizzesSnapshot.docs) {
    var date = quiz['startDate'];
    DateTime startDate = date is Timestamp ? date.toDate() : DateTime.parse(date);

    events.add({
      'type': 'Quiz',
      'title': quiz['title'],
      'date': startDate,
      'notificationDate': startDate.subtract(Duration(days: 1)), // Notification date
      'courseId': quiz['courseId'],
    });
  }

  // Sort events by date (ascending order)
  events.sort((a, b) => a['date'].compareTo(b['date']));

  // Group events by day of the week
  Map<String, List<Map<String, dynamic>>> schedule = {};

  for (var event in events) {
    String day = DateFormat('EEEE').format(event['date']); // Day name (e.g., Monday)
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

  /// Checks and triggers notifications for events happening tomorrow
 /// Checks and triggers notifications for events happening tomorrow
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

  // Function to get the date of a specific day relative to today
  String getFormattedDate(DateTime date) {
    return DateFormat('d MMMM').format(date); // e.g., "20 January"
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
            checkNotifications(schedule); // Check for notifications

            final daysOfWeek = [
              'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
            ];

            // Calculate the dates for each day of the week starting from today
            DateTime today = DateTime.now();
            List<DateTime> daysOfWeekDates = List.generate(7, (index) {
              return today.subtract(Duration(days: today.weekday - 1)).add(Duration(days: index));
            });

            // Define dynamic time slots based on events' start times
            Set<String> timeSlotsSet = Set();

            for (var day in schedule.values) {
              for (var event in day) {
                DateTime eventTime = event['date'];
                String timeSlot =
                    '${eventTime.hour.toString().padLeft(2, '0')}:${eventTime.minute >= 30 ? '30' : '00'}';
                timeSlotsSet.add(timeSlot);
              }
            }

            final timeSlots = timeSlotsSet.toList()..sort(); // Sort the time slots

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    // Header row: Days of the week with dates
                    Row(
                      children: [
                        Container(width: 50, height: 50), // Placeholder for time column
                        ...List.generate(7, (index) {
                          String day = daysOfWeek[index];
                          String formattedDate = getFormattedDate(daysOfWeekDates[index]);
                          return Container(
                            width: 150,
                            height: 50,
                            color: Colors.grey[300],
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
                    // Time and tasks grid
                    Column(
                      children: timeSlots.map((time) {
                        return Row(
                          children: [
                            // Time column
                            Container(
                              width: 50,
                              height: 100,
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: Text(time),
                            ),
                            // Task cells for each day
                            ...daysOfWeek.map((day) {
                              final dayEvents = schedule[day] ?? [];
                              final tasksAtTime = dayEvents.where((event) {
                                // Round event times to the nearest half-hour slot
                                DateTime eventTime = event['date'];
                                int eventMinute = eventTime.minute;
                                String eventTimeSlot =
                                    '${eventTime.hour.toString().padLeft(2, '0')}:${eventMinute >= 30 ? '30' : '00'}';

                                return eventTimeSlot == time;
                              }).toList();

                              return Container(
                                width: 150,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black12),
                                  color: tasksAtTime.isEmpty ? Colors.blue[50] : Colors.orange[100],
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
            );
          }
        },
      ),
    );
  }
}
