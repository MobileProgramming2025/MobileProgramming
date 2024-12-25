import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';

class ListUsersScreen extends StatefulWidget {
  const ListUsersScreen({super.key});

  @override
  State<ListUsersScreen> createState() => _ListUsersScreenState();
}

class _ListUsersScreenState extends State<ListUsersScreen> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      body: FutureBuilder(
        future: null,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Text(user.role),
                onTap: () {
                  // Navigate to user details
                },
              );
            }
          );
        },
      ),
    );
  }
}