import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AdminScreens/UserCoursesScreen.dart';
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
  List<User> _filteredUsers = [];
  String _sortCriteria = 'name'; // Default sorting by name
  String _filterRole = 'All'; // Default to no filtering
  // late List<Map<String, dynamic>> users;
  final UserService _userService = UserService();
  User? _recentlyDeletedUser; // For undo functionality
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

void _deleteUser(int index) async {
  setState(() {
    _recentlyDeletedUser = _filteredUsers[index];
    _recentlyDeletedIndex = index;
  });

  setState(() {
    _filteredUsers.removeAt(index);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Deleted ${_recentlyDeletedUser!.name}'),
      action: SnackBarAction(
        label: "Undo",
        onPressed: () {
          _undoDelete();
        },
      ),
    ),
  );

  await Future.delayed(const Duration(seconds: 7)); 

  if (_recentlyDeletedUser != null && _recentlyDeletedIndex != null) {
    try {
      await _userService.deleteUser(_recentlyDeletedUser!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully!')),
      );

      setState(() {
        _futureUsers = _userService.getAllUsers();
      });
    } catch (e) {
      setState(() {
        _filteredUsers.insert(_recentlyDeletedIndex!, _recentlyDeletedUser!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }
}


void _undoDelete() {
  if (_recentlyDeletedUser != null && _recentlyDeletedIndex != null) {
    setState(() {
      _filteredUsers.insert(_recentlyDeletedIndex!, _recentlyDeletedUser!);
    });

    setState(() {
      _recentlyDeletedUser = null;
      _recentlyDeletedIndex = null;
    });
  }
}


  void _startAdvising() async {
    try {
      print("start");
      final userList = await _futureUsers;
      final userMaps = userList
          .map((user) => {
                'id': user.id,
                'taken_courses': user.takenCourses,
                'enrolled_courses': user.enrolledCourses,
                'role': user.role,
              })
          .toList();

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
        title: const Text('Users List'),
        // actions: [
        //   DropdownButton<String>(
        //     value: _sortCriteria,
        //     items: const [
        //       DropdownMenuItem(
        //         value: 'name',
        //         child: Text('Sort by Name'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'email',
        //         child: Text('Sort by E-mail'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'role',
        //         child: Text('Sort by Role'),
        //       ),
        //     ],
        //     onChanged: (value) {
        //       setState(() {
        //         _sortCriteria = value!;
        //       });
        //     },
        //   ),
        //   DropdownButton<String>(
        //     value: _filterRole,
        //     items: const [
        //       DropdownMenuItem(
        //         value: 'All',
        //         child: Text('All roles'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'Doctor',
        //         child: Text('Doctor'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'Teaching Assistant',
        //         child: Text('Teaching Assistant'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'Student',
        //         child: Text('Student'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'Admin',
        //         child: Text('Admin'),
        //       ),
        //     ],
        //     onChanged: (value) {
        //       setState(() {
        //         _filterRole = value!;
        //       });
        //     },
        //   ),
        // ],
      ),
      drawer: AdminDrawer(user: widget.admin),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _sortCriteria,
                  items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Sort by Name'),
                    ),
                    DropdownMenuItem(
                      value: 'email',
                      child: Text('Sort by E-mail'),
                    ),
                    DropdownMenuItem(
                      value: 'role',
                      child: Text('Sort by Role'),
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
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All roles'),
                    ),
                    DropdownMenuItem(
                      value: 'Doctor',
                      child: Text('Doctor'),
                    ),
                    DropdownMenuItem(
                      value: 'Teaching Assistant',
                      child: Text('Teaching Assistant'),
                    ),
                    DropdownMenuItem(
                      value: 'Student',
                      child: Text('Student'),
                    ),
                    DropdownMenuItem(
                      value: 'Admin',
                      child: Text('Admin'),
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
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
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

                _filterAndSortUsers(snapshot.data!);

                return ListView.builder(
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return InkWell(
                      onTap: () {
                        if (user.role == "Admin") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'This action isn\'t suitable for this user')),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserCoursesScreen(user: user),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.email,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    user.role,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
