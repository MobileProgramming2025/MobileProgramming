import 'package:flutter/material.dart';
import 'package:mobileprogramming/screens/doctorScreens/ChatRoomScreen.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/services/user_service.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSearching = false;
  User? _chatUser;
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
          _chatUser = user;
          _isSearching = false;
        });
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
            // Show user details if found
            if (_chatUser != null) ...[
              Text('User Found: ${_chatUser!.name}'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Navigate to chat room
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatRoomScreen(
                        currentUserId: widget.userId,
                        chatUserId: _chatUser!.id,
                        chatUserName: _chatUser!.name,
                      ),
                    ),
                  );
                },
                child: const Text('Start Chat'),
              ),
            ],
            // Display error if no user is found
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
