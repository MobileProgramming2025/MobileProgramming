import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/User.dart';

class ChatRoomScreen extends StatefulWidget {
  final User doctor;
  final String roomId;

  const ChatRoomScreen({super.key, required this.doctor, required this.roomId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<String> messages = [];  // List to hold chat messages

  @override
  void initState() {
    super.initState();
    // Fetch the initial messages if required.
    _loadMessages();
  }

  void _loadMessages() {
    // Load messages from backend (e.g., Firebase, etc.)
    setState(() {
      messages = [
        'Hello, how can I help you today?',
        'I have a question about the course material.',
      ];
    });
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add(_messageController.text); // Add the new message
      });
      _messageController.clear();  // Clear the message input field
      // Optionally, send the message to the backend.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room ${widget.roomId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                  subtitle: Text('Sender: ${widget.doctor.name}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
