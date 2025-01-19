import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String currentUserId;
  final String chatUserId;
  final String chatUserName;

  const ChatRoomScreen({
    super.key,
    required this.currentUserId,
    required this.chatUserId,
    required this.chatUserName,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a message
  void _sendMessage() async {
    final messageText = _messageController.text;
    if (messageText.isNotEmpty) {
      final newMessage = {
        'sender': widget.currentUserId,
        'receiver': widget.chatUserId,
        'text': messageText,
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore
            .collection('chats')
            .doc(getChatId())
            .collection('messages')
            .add(newMessage);
        _messageController.clear();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error sending message")),
        );
      }
    }
  }

  // Get the chat ID (it can be based on both users' IDs)
  String getChatId() {
    List<String> ids = [widget.currentUserId, widget.chatUserId];
    ids.sort();
    return ids.join('_');
  }

  // Stream to fetch messages from Firestore
  Stream<List<Map<String, dynamic>>> _getMessages() {
    return _firestore
        .collection('chats')
        .doc(getChatId())
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatUserName}'),
      ),
      body: Column(
        children: [
          // List of messages fetched from Firestore
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>( 
              stream: _getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender'] == widget.currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue[200]
                              : const Color.fromARGB(255, 134, 14, 14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message['text'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
