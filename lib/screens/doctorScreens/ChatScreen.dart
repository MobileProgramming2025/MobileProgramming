import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/doctorScreens/ChatRoomScreen.dart';
import 'package:mobileprogramming/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSearching = false;
  String? _errorMessage;

  final UserService _userService = UserService();  // Assuming you have a service to fetch users

  // Method to search for a user by email
  void _searchUserByEmail() async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final user = await _userService.fetchUserByEmail(_emailController.text);
      if (user != null) {
        setState(() {
          _isSearching = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              currentUserId: widget.userId,
              chatUserId: user.id,
              chatUserName: user.name,
            ),
          ),
        );
      } else {
        setState(() {
          _isSearching = false;
          _errorMessage = "User not found";
        });
      }
    } catch (error) {
      setState(() {
        _isSearching = false;
        _errorMessage = "Error fetching user: $error";
      });
    }
  }

  // Method to fetch conversations for the current user
  Stream<List<Map<String, dynamic>>> _getConversations() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('conversations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search by Email
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter Email to Chat',
                border: OutlineInputBorder(),
                suffixIcon: _isSearching
                    ? const CircularProgressIndicator()
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _searchUserByEmail,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // Display list of conversations
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getConversations(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final conversations = snapshot.data!;
                  return ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final lastMessage = conversation['lastMessage'];
                      final chatUserName = conversation['chatUserName'];
                      final chatUserId = conversation['chatUserId'];

                      return ListTile(
                        title: Text(chatUserName),
                        subtitle: Text(lastMessage),
                        onTap: () {
                          // Navigate to chat room
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(
                                currentUserId: widget.userId,
                                chatUserId: chatUserId,
                                chatUserName: chatUserName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Display error if no conversations found
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
