import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/userDrawer.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text("User Home"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const UserDrawer(),
        
      body: Center(child: Text("Welcome to User Home!"))
    );
    
  }
}
