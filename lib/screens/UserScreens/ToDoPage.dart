

import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/services/TrelloApi.dart';
import 'package:mobileprogramming/models/TrelloCard.dart';
import 'package:mobileprogramming/screens/partials/UserBottomNavigationBar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trello To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'New Task',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final cards = snapshot.data!;
                  return ListView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return ListTile(
                        title: Text(card.name),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No tasks found.'));
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: UserBottomNavigationBar(user: widget.user),

    );
  }
}


