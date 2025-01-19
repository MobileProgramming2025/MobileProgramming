import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/User.dart';
import 'package:mobileprogramming/screens/doctorScreens/chat_roon.dart';

class ChatScreen extends StatelessWidget {
  final User doctor;

  const ChatScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality if required
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 10,  // For now, showing 10 rooms (replace with dynamic data)
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Chat Room ${index + 1}'),
            subtitle: Text('Recent Message'),
            onTap: () {
              // Navigate to chat room
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    doctor: doctor,
                    roomId: index.toString(), // Room ID or unique identifier
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
