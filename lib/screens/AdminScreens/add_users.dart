import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:uuid/uuid.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final Uuid _uuid = Uuid();

  String? _selectedRole;
  String? _selectedDepartment;

  final List<String> _roles = ['Student', 'Doctor', 'Teaching Assistant', 'Admin'];
  final List<String> _departments = [
    'Computer Science',
    'Business',
    'Engineering',
    'Architecture'
  ];
  

  Future<void> _addUser() async {
    String userId = _uuid.v4();


    
    final _firstAdded = DateTime.utc(2021, DateTime.november, 9);
    final _currentYear = DateTime.now();
    final educationYear = _currentYear.year - _firstAdded.year;
  
    User newUser = User(
      id: userId,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole ?? 'Unknown',
      department: _selectedDepartment ?? 'Unknown',
      takenCourses: [],
      enrolledCourses: [],
      addedDate: _firstAdded,
      year: (educationYear + 1).toString(),
      
    );

    try {
      await newUser.saveToFirestore();
      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User added successfully!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add user: $e')),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _selectedRole = null;
      _selectedDepartment = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a user'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                      
                    ),
                    obscureText: true,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please, enter your password.";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters.";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: _roles.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(
                          role,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    items: _departments.map((department) {
                      return DropdownMenuItem(
                        value: department,
                        child: Text(
                          department,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(), 
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _addUser,
                      child: Text(
                        'Add User',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
