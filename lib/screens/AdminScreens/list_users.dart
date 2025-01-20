import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/screens/partials/profile.dart';
import 'package:mobileprogramming/services/user_service.dart';

class ListUsersScreen extends StatefulWidget {
  final User admin;
  const ListUsersScreen({super.key, required this.admin});

  @override
  State<ListUsersScreen> createState() => _ListUsersScreenState();
}

class _ListUsersScreenState extends State<ListUsersScreen> {
  late Future<List<User>> _futureUsers;
  List<User> _filteredUsers = [];
  String _sortCriteria = 'name';  // Default sorting by name
  String _filterRole = 'All';   // Default to no filtering 
  // late List<Map<String, dynamic>> users;
  final UserService _userService = UserService();
  User? _recentlyDeletedUser;   // For undo functionality
  int? _recentlyDeletedIndex;

  @override
  void initState() {
    super.initState();
    _futureUsers = _userService.getAllUsers();
  }

  void _filterAndSortUsers(List<User> users) {
    // Filter users
    _filteredUsers = users.where((user) {
      return _filterRole == 'All' || user.role == _filterRole;
    }).toList();

    // Sort users 
    _filteredUsers.sort((a, b) {
      if (_sortCriteria == 'name') {
        return a.name.compareTo(b.name);
      } else if (_sortCriteria == 'email') {
        return a.email.compareTo(b.email);
      } else if (_sortCriteria == 'role') {
        return a.role.compareTo(b.role);
      }
      return 0;
    });
  }

  void _deleteUser(int index) {
    setState(() {
      _recentlyDeletedUser = _filteredUsers.removeAt(index);
      _recentlyDeletedIndex = index;
    });

    // Show snackbar with undo option
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted ${_recentlyDeletedUser!.name}'
        ),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            _undoDelete();
          },
        ),
      ),
    );
  }

  void _undoDelete() {
    if (_recentlyDeletedUser != null && _recentlyDeletedIndex != null) {
      setState(() {
        _filteredUsers.insert(_recentlyDeletedIndex!, _recentlyDeletedUser!);
      });
    }
  }

  void _startAdvising() async {
    try {
      print ("start");
      // Await the future and map User objects to Map<String, dynamic>
      final userList = await _futureUsers;
      final userMaps = userList
          .map((user) => {
                'id': user.id,
                'taken_courses': user.takenCourses,
                'enrolled_courses': user.enrolledCourses,
                'role':user.role,
              })
          .toList();
      // Call startAdvising with the mapped user data
      await _userService.startAdvising(userMaps);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advising Started!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start advising: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User List'),
        actions: [
          DropdownButton<String>(
            value: _sortCriteria,
            items: [
              DropdownMenuItem(
                value: 'name',
                child: Text(
                  'Sort by Name'
                ),
              ),
              DropdownMenuItem(
                value: 'email',
                child: Text(
                  'Sort by E-mail'
                ),
              ),
              DropdownMenuItem(
                value: 'role',
                child: Text(
                  'Sort by Role'
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _sortCriteria = value!;
              });
            },
          ),
          DropdownButton<String>(
            value: _filterRole,
            items: [
              DropdownMenuItem(
                value: 'All',
                child: Text(
                  'All roles'
                ),
              ),
              DropdownMenuItem(
                value: 'Doctor',
                child: Text(
                  'Doctor'
                ),
              ),
              DropdownMenuItem(
                value: 'Teaching Assistant',
                child: Text(
                  'Teaching Assistant'
                ),
              ),
              DropdownMenuItem(
                value: 'Student',
                child: Text(
                  'Student'
                ),
              ),
              DropdownMenuItem(
                value: 'Admin',
                child: Text(
                  'Admin'
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _filterRole = value!;
              });
            },
          ),
        ],
      ),
      drawer: AdminDrawer(user: widget.admin),
      body: FutureBuilder<List<User>>(
        future: _futureUsers,
        builder: (context, snapshot) {
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

          // Filter and sort users
          _filterAndSortUsers(snapshot.data!);

          // final users = snapshot.data!;
          return ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return ListTile(
                title: Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.role,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _deleteUser(index);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to user details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(user: user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: ElevatedButton(
        onPressed: _startAdvising,
        child: Text(
          'Start Advising...',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
