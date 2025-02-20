// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:mobileprogramming/models/Course.dart';
// import 'package:mobileprogramming/screens/partials/profile.dart';
// import 'package:mobileprogramming/services/CourseService.dart';
// import 'package:mobileprogramming/services/user_service.dart';
// import 'package:mobileprogramming/models/user.dart';

// class DoctorDashboard extends StatefulWidget {
//   final User doctor;

//   const DoctorDashboard({super.key, required this.doctor});

//   @override
//   State<DoctorDashboard> createState() => _DoctorDashboardState();
// }

// class _DoctorDashboardState extends State<DoctorDashboard> {
//   bool isLoading = true;

//   DateTime _selectedDate = DateTime.now();
//   DateTime _focusedDate = DateTime.now();
//   int _currentIndex = 0;
//   final CourseService _courseService = CourseService();
//   final UserService _userService = UserService();

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     await Future.delayed(Duration(seconds: 2));
//     setState(() {

//       isLoading = false;
//     });
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });

//     switch (index) {
//       case 0:
//         break;
//       case 1:
//         Navigator.pushNamed(
//           context,
//           '/view_Instructor_courses',
//           arguments: widget.doctor.id,
//         );
//         break;
//       case 2:
//         Navigator.pushNamed(context, '/calendar');
//         break;
//       case 3:
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ProfileScreen(user: widget.doctor),
//             ));
//         break;
//       case 4:
//         _logout();
//         break;
//     }
//   }

//   void _logout() async {
//     final shouldLogout = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Logout'),
//           content: Text('Are you sure you want to logout?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(false),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(true),
//               child: Text('Logout'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldLogout == true) {
//       // Handle your logout logic here
//       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Hello, Doctor ${widget.doctor.name}!",
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,),
//             ),
//             CircleAvatar(
//               backgroundImage: AssetImage("assets/userImage.png"),
//               radius: 20,
//             ),
//           ],
//         ),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Theme.of(context).canvasColor,
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               blurRadius: 8,
//                               spreadRadius: 2,
//                             ),
//                           ],
//                         ),
//                         child: TableCalendar(
//                           firstDay: DateTime.utc(2000, 1, 1),
//                           lastDay: DateTime.utc(2100, 12, 31),
//                           focusedDay: _focusedDate,
//                           selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
//                           onDaySelected: (selectedDay, focusedDay) {
//                             setState(() {
//                               _selectedDate = selectedDay;
//                               _focusedDate = focusedDay;
//                             });
//                           },
//                           headerStyle: HeaderStyle(
//                             formatButtonVisible: false,
//                             titleCentered: true,
//                             decoration: BoxDecoration(
//                               color: Theme.of(context).colorScheme.primary,
//                               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                             ),
//                             titleTextStyle: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 20,
//                             ),
//                             leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
//                             rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
//                           ),
//                           calendarStyle: CalendarStyle(
//                             todayDecoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 255, 255, 255),
//                               border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
//                               shape: BoxShape.circle,
//                             ),
//                             selectedDecoration: BoxDecoration(
//                               color: Theme.of(context).colorScheme.primary,
//                               shape: BoxShape.circle,
//                             ),
//                             defaultDecoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                             ),
//                             weekendDecoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.grey.withOpacity(0.1),
//                             ),
//                             outsideDecoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                             ),
//                             defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
//                             weekendTextStyle: TextStyle(color: Colors.red),
//                             todayTextStyle: TextStyle(
//                               color: const Color.fromARGB(255, 56, 3, 3),
//                               fontWeight: FontWeight.bold,
//                             ),
//                             selectedTextStyle: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             outsideDaysVisible: false,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // Progress Section
//                     Text(
//                       "Your Courses",
//                       style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black),
//                     ),
//                     SizedBox(height: 10),
//                     // Row(
//                     //   children: courses
//                     //       .map(
//                     //         (course) => Expanded(
//                     //           child: ProgressCard(
//                     //             title: course,
//                     //             progress: (courses.indexOf(course) + 1) * 30,
//                     //             color: Color(0xFFDED6FF),
//                     //           ),
//                     //         ),
//                     //       )
//                     //       .toList(),
//                     // ),

//                     StreamBuilder<List<Map<String, dynamic>>>(
//                       stream: _courseService.fetchEnrolledCoursesByUserId(widget.doctor.id),
//                       builder: (context, snapshot) {
//                         // Handling different connection states
//                         if (snapshot.connectionState == ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         } else if (snapshot.hasError) {
//                           return Center(
//                             child: Text('Error: ${snapshot.error}'),
//                           );
//                         } else if (!snapshot.hasData ||
//                             snapshot.data!.isEmpty) {
//                           return Center(
//                             child: Text(
//                               'No Courses Found',
//                               style: Theme.of(context).textTheme.bodyLarge,
//                             ),
//                           );
//                         }

//                         final instructorCourses = snapshot.data!;

//                         // Flatten the list of courses for all users
//                         final allInstructorCourses = instructorCourses
//                             .expand((user) =>
//                                 user['enrolled_courses'] as List<dynamic>)
//                             .toList();

//                         return GridView.builder(
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 16,
//                             mainAxisSpacing: 16,
//                           ),
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: allInstructorCourses.length,
//                           itemBuilder: (context, index) {
//                             final course = allInstructorCourses[index];

//                             return Card(
//                               elevation: 4,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     course['name'],
//                                     style:
//                                         Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   Text(
//                                     course['code'],
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium
//                                         ?.copyWith(
//                                           color: Colors.black,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),

//                     SizedBox(height: 20),

//                     // Courses Section
//                     Text(
//                       "All Courses",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 10),

//                     StreamBuilder<List<Course>>(
//                       stream: _courseService.getCoursesByDepartmentId(
//                           widget.doctor.departmentId!),
//                       builder: (context, snapshot) {
//                         // Handling different connection states
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         } else if (snapshot.hasError) {
//                           return Center(
//                             child: Text('Error: ${snapshot.error}'),
//                           );
//                         } else if (!snapshot.hasData ||
//                             snapshot.data!.isEmpty) {
//                           return Center(
//                             child: Text(
//                               'No Courses Found in this Department',
//                               style: Theme.of(context).textTheme.bodyLarge,
//                             ),
//                           );
//                         }
//                         final courses = snapshot.data!;

//                         return GridView.builder(
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 16,
//                             mainAxisSpacing: 16,
//                           ),
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(),
//                           itemCount: courses.length,
//                           itemBuilder: (context, index) {
//                             final course = courses[index];

//                             return Card(
//                               elevation: 4,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.book,
//                                     size: 40,
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     course.name,
//                                     style:
//                                         Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   Text(
//                                     'Course Code: ${course.code}',
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium
//                                         ?.copyWith(
//                                           color: Colors.black,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey[100],
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(30),
//             topRight: Radius.circular(30),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 20,
//             ),
//           ],
//         ),
//         child: Container(
//           margin: EdgeInsets.only(bottom: 5),
//           height: 60,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(30),
//               topRight: Radius.circular(30),
//               bottomRight: Radius.circular(30),
//               bottomLeft: Radius.circular(30),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 5,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: BottomNavigationBar(
//             currentIndex: _currentIndex,
//             type: BottomNavigationBarType.fixed,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             selectedItemColor: Colors.indigo,
//             unselectedItemColor: Colors.orange,
//             showSelectedLabels: true,
//             showUnselectedLabels: false,
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.house_rounded), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.school), label: "Courses"),
//               BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
//               BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//               BottomNavigationBarItem(icon: Icon(Icons.exit_to_app_sharp), label: "Logout"),
//             ],
//             onTap: _onItemTapped,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProgressCard extends StatelessWidget {
//   final String title;
//   final double progress;
//   final Color color;

//   const ProgressCard({
//     required this.title,
//     required this.progress,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: color,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             LinearProgressIndicator(value: progress / 100),
//             SizedBox(height: 8),
//             Text('${(progress).toStringAsFixed(0)}% Completed'),
//           ],
//         ),
//       ),
//     );
//   }
// }
