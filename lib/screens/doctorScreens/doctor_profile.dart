import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/doctorDrawer.dart';

class DoctorProfile extends StatefulWidget {
  final User doctor;

  const DoctorProfile({super.key, required this.doctor});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  late User doctor;

  @override
  void initState() {
    super.initState();
    // Initialize the doctor instance from the widget's doctor property
    doctor = widget.doctor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
       leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const DoctorDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${doctor.name}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Email: ${doctor.email}',
              style: TextStyle(
                fontSize: 16
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Role: ${doctor.role}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8), 

            Text(
              'Department: ${doctor.department}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                // Handle edit profile
              },
              child: Text('Edit Profile')
            ),       
          ],
        ),
      ),
    );
  }
}