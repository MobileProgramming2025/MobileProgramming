import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/UserDrawer.dart';
import 'package:mobileprogramming/services/TrelloApi.dart';
import 'package:mobileprogramming/models/TrelloCard.dart';
import 'package:mobileprogramming/screens/partials/UserBottomNavigationBar.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening URLs

class ToDoPage extends StatefulWidget {
  final User user;

  const ToDoPage({super.key, required this.user});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final _api = TrelloApi('O9q3Qdbz'); // Replace with your board ID
  final _listId = '678cf2cc7e25dff5b56647a2'; // Replace with your list ID
  late Future<List<TrelloCard>> _cardsFuture;

  final TextEditingController _textController = TextEditingController();

  final Uri _boardUrl = Uri.parse('https://trello.com/b/O9q3Qdbz'); // Board URL

  @override
  void initState() {
    super.initState();
    _cardsFuture = _api.fetchCards(_listId);
  }

  void _addCard(String cardName) async {
    if (cardName.isNotEmpty) {
      try {
        await _api.addCard(_listId, cardName);
        setState(() {
          _cardsFuture = _api.fetchCards(_listId);
        });
        _textController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _deleteCard(String cardId) async {
    try {
      await _api.deleteCard(cardId);
      setState(() {
        _cardsFuture = _api.fetchCards(_listId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _openBoard() async {
    if (await canLaunchUrl(_boardUrl)) {
      await launchUrl(_boardUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the Trello board URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trello To-Do List'),
        backgroundColor: Colors.indigoAccent,
        elevation: 2,
       
      ),
      drawer: UserDrawerScreen(user: widget.user),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Add a New Task',
                hintText: 'Enter task name',
                filled: true,
                fillColor: Colors.indigo[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add, color: Colors.indigoAccent),
                  onPressed: () => _addCard(_textController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TrelloCard>>(
              future: _cardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final cards = snapshot.data!;
                  if (cards.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks available. Add a task to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigoAccent,
                            child: const Icon(
                              Icons.task_alt,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            card.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteCard(card.id),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('No tasks found'),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('View Board'),
        icon: const Icon(Icons.open_in_browser),
        onPressed: _openBoard,
      ),
      bottomNavigationBar: UserBottomNavigationBar(user: widget.user),
    );
  }
}
