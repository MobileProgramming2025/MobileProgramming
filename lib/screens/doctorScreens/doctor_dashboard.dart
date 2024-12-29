import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/CourseList.dart';
import 'package:mobileprogramming/screens/UserScreens/profile.dart';

class DoctorDashboard extends StatefulWidget {
  final User doctor;

  const DoctorDashboard({super.key, required this.doctor});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  bool isLoading = true;
  List<String> courses = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle Notifications
            },
          ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Hello, ${widget.doctor.name}',
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
                      builder: (context) => ProfileScreen(user: widget.doctor),
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
      ),

      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Doctor ${widget.doctor.name}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Navigate to course details
                          },
                          child: Card(
                            elevation: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book,
                                  size: 40,
                                  color: Colors.blue,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  courses[index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
