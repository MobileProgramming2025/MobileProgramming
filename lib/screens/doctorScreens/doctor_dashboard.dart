import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/CourseDetailScreen.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/CourseList.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorDashboard extends StatefulWidget {
  final User doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  bool isLoading = true;
  List<String> courses = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  int _currentIndex = 0; // Track the selected tab

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      courses = ['Course 1', 'Course 2', 'Course 3'];
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/Doctor-dashboard');
        break;
      case 1:
         Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseListPage(),
          )
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/calendar');
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(user: widget.doctor),
          )
        );
        break;
      case 4:
        _logout();
        break;
    }
  }

  void _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Handle your logout logic here
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDECF8),
      appBar: AppBar(
        backgroundColor: Color(0xFFEDECF8),
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Hello, Doctor ${widget.doctor.name}!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
              ),
            ),
            CircleAvatar(
              backgroundImage: AssetImage("assets/userImage.png"),
              radius: 20,
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Real Calendar Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDate, day),
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
                              color: Color(0xFF8E77FF),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16)),
                            ),
                            titleTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            leftChevronIcon:
                                Icon(Icons.chevron_left, color: Colors.white),
                            rightChevronIcon: Icon(Icons.chevron_right,
                                color: Colors.white),
                          ),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: Color(0xFF8E77FF), width: 2),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Color(0xFF8E77FF),
                              shape: BoxShape.circle,
                            ),
                            defaultDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            weekendDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            outsideDecoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            defaultTextStyle: TextStyle(color: Colors.black),
                            weekendTextStyle: TextStyle(color: Colors.red),
                            todayTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            selectedTextStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            outsideDaysVisible: false,
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            weekendStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Progress Section
                    Text(
                      "Your Courses",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: courses
                        .map(
                          (course) => Expanded(
                            child: ProgressCard(
                              title: course,
                              progress: (courses.indexOf(course) + 1) * 30,
                              color: Color(0xFFDED6FF),
                            ),
                          ),
                        )
                        .toList(),
                    ),
                    SizedBox(height: 20),

                    // Courses Section
                    Text(
                      "All Courses",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
                        )
                      ),
                    SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/course-detail', // Specify your course detail route here
                              arguments: courses[index], // Pass course data if needed
                            );
                          },
                          child: Card(
                            elevation: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book,
                                  size: 40,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  courses[index],
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color.fromARGB(255, 69, 0, 187),
          unselectedItemColor: const Color.fromARGB(255, 223, 101, 26),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.house_rounded), 
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school), 
              label: "Courses"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: "Calendar"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person), 
              label: "Profile"
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app_sharp), 
              label: "Logout"
            ),
          ],
          onTap: _onItemTapped, // Call the method on tap
        ));
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final int progress;
  final Color color;

  const ProgressCard({
    super.key, 
    required this.title,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cloud, color: Colors.black),
              Spacer(),
              Icon(Icons.more_vert, color: Colors.black),
            ],
          ),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(height: 10),
          Text("Progress: $progress%"),
        ],
      ),
    );
  }
}
