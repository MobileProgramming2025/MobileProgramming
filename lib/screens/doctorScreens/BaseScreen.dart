import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final ValueChanged<int> onTabTapped;

  const BaseScreen({
    Key? key,
    required this.currentIndex,
    required this.body,
    required this.onTabTapped,
  }) : super(key: key);

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
              "Hello, Doctor!", 
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            CircleAvatar(
              backgroundImage: AssetImage("assets/userImage.png"),
              radius: 20,
            ),
          ],
        ),
      ),
      body: body,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 5),
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color.fromARGB(255, 69, 0, 187),
            unselectedItemColor: const Color.fromARGB(255, 223, 101, 26),
            showSelectedLabels: true,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.house_rounded), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.school), label: "Courses"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined), label: "Calendar"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.exit_to_app_sharp), label: "Logout"),
            ],
            onTap: onTabTapped, // Call the method on tap
          ),
        ),
      ),
    );
  }
}
