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
  List<String> _emailSuggestions = [];

  final UserService _userService = UserService();

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

  void _getEmailSuggestions() async {
    final query = _emailController.text.toLowerCase();
    if (query.isNotEmpty) {
      final suggestions = await _userService.fetchEmailSuggestions(query);
      setState(() {
        _emailSuggestions = suggestions;
      });
    } else {
      setState(() {
        _emailSuggestions = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _emailController.addListener(_getEmailSuggestions);
  }

  @override
  void dispose() {
    _emailController.removeListener(_getEmailSuggestions);
    _emailController.dispose();
    super.dispose();
  }

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
        title: const Text('Chats'),
        backgroundColor: Colors.teal,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search by Email
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter email to chat...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: _isSearching
                      ? const CircularProgressIndicator()
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Show email suggestions
            if (_emailSuggestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _emailSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_emailSuggestions[index]),
                      onTap: () async {
                        // Set the email in the text field
                        _emailController.text = _emailSuggestions[index];
                        setState(() {
                          _emailSuggestions = [];
                        });

                        _searchUserByEmail();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
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

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              chatUserName[0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            chatUserName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
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
                        ),
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
