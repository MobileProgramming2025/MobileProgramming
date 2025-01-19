import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Message.dart';
import 'package:mobileprogramming/services/ChatService.dart';

class ChatScreen extends StatelessWidget {
  final String doctorId;

  const ChatScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Doctor"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Chat UI elements (This can be expanded with a more complex chat interface)
            Expanded(
              child: ListView.builder(
                itemCount: 0, // You'll want to populate this with actual chat messages
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Doctor's message"),
                  );
                },
              ),
            ),
            // Text input for sending messages
            TextField(
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                suffixIcon: Icon(Icons.send),
              ),
              onSubmitted: (message) {
                // Handle sending the message to the doctor using doctorId
                print('Sending message: $message to doctor $doctorId');
              },
            ),
          ],
        ),
      ),
    );
  }
}
