import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminDashboard extends StatefulWidget {
  final User admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _numAdmins = 0;
  int _numStudents = 0;
  int _numDoctors = 0;
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate;

  List<String> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
    _fetchRecentActivities();
  }

  void _fetchStatistics() async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final adminsQuery =
        await usersCollection.where('role', isEqualTo: 'Admin').get();
    final studentsQuery =
        await usersCollection.where('role', isEqualTo: 'Student').get();
    final doctorsQuery =
        await usersCollection.where('role', isEqualTo: 'Doctor').get();

    setState(() {
      _numAdmins = adminsQuery.docs.length;
      _numStudents = studentsQuery.docs.length;
      _numDoctors = doctorsQuery.docs.length;
    });
  }

  void _fetchRecentActivities() async {
    // Simulating fetching recent activities from Firestore
    // Replace this with Firestore query if data exists in a collection
    setState(() {
      _recentActivities = [
        "Admin John updated the schedule.",
        "Student Sarah submitted an assignment.",
        "Doctor Jane added a new course.",
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: AdminDrawer(user: widget.admin),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatisticCard('Admins', _numAdmins, Colors.indigo[800]!),
                _buildStatisticCard('Students', _numStudents, Colors.indigo[800]!),
                _buildStatisticCard('Doctors', _numDoctors, Colors.indigo[800]!),
              ],
            ),
            const SizedBox(height: 16),
            _buildRecentActivitiesSection(),
            const SizedBox(height: 16),
            _buildCalendarSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String title, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recent Activities",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentActivities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.circle, size: 12, color: Colors.indigo),
                  title: Text(
                    _recentActivities[index],
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
            _focusedDate = focusedDay;
          });
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          weekendDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.1),
          ),
          defaultTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface),
          weekendTextStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
