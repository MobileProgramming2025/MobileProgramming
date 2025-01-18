import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/user_service.dart';

class ListUsersScreen extends StatefulWidget {
  final User admin;
  const ListUsersScreen({super.key, required this.admin});

  @override
  State<ListUsersScreen> createState() => _ListUsersScreenState();
}

class _ListUsersScreenState extends State<ListUsersScreen> {
  late Future<List<User>> _futureUsers;
  final UserService _userService = UserService();

  void _enroll() async {
    try {
      _userService.enrollStudent();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Students are enrolled Sucessfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll students: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _futureUsers = _userService.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
      ),
      drawer: AdminDrawer(user: widget.admin),

      body: FutureBuilder(
        future: _futureUsers,
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No users found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  user.role,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  // Navigate to user details
                },
              );
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _enroll,
        child: Text(
          'Enroll Students To Courses',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
