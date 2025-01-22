import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/AdminScreens/Add_department_screen.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';

class ViewDepartmentsScreen extends StatefulWidget {
  final User admin;
  const ViewDepartmentsScreen({super.key, required this.admin});

  @override
  State<ViewDepartmentsScreen> createState() => _ViewDepartmentsScreenState();
}

class _ViewDepartmentsScreenState extends State<ViewDepartmentsScreen> {
  final DepartmentService departmentService = DepartmentService();
  late Stream<List<Map<String, dynamic>>> _departmentsStream;

  @override
  void initState() {
    super.initState();
    // Initializing the stream to get department data in real time
    _departmentsStream = departmentService.getAllDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Departments"),
      ),
      drawer: AdminDrawer(user: widget.admin),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          // Using Stream to get real-time updates
          stream: _departmentsStream,
          builder: (context, snapshot) {
            // Handling different connection states
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
                  'No Departments Found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            final departments = snapshot.data!; // Extract department data

            return ListView.builder(
              // Display list of departments
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index]; // Current department
                final departmentId = department['id']; // Extracting the ID

                return InkWell(
                  // Makes the card clickable
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/view_department_courses',
                      arguments: departmentId, // Pass department data
                    );
                  },

                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            department['name'],
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Department Capacity: ${department['capacity']}',
                            style: Theme.of(context).textTheme.bodyLarge,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDepartmentScreen(admin: widget.admin),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}