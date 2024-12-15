// home_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await AuthService().logout();
            Navigator.pushReplacementNamed(context, '/');
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}
