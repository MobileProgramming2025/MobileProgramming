import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/services/user_service.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

class GoogleSignUpScreen extends StatefulWidget {
  const GoogleSignUpScreen({super.key});

  @override
  State<GoogleSignUpScreen> createState() {
    return _GoogleSignUpScreenState();
  }
}

class _GoogleSignUpScreenState extends State<GoogleSignUpScreen> {
  final UserService _userService = UserService();
  final DepartmentService _departmentService = DepartmentService();
  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();

  var _selectedYear = '1';
  var _selectedDepartment = '';
  var _selectedRole;

  final List<String> years = ['1', '2', '3', '4', '5'];
  final List<String> roles = [
    'Student',
    'Doctor',
    'Teaching Assistant',
  ];

  //hold value of textfields, called whnerver button is pressed
  void _submit(BuildContext context) {
    final isValid = _form.currentState!.validate();
    //! -> will not be null, filled later, validate()-> bool
    if (isValid) {
      _form.currentState!.save();
      _saveUser();
      _handleGoogleSignUp(context);
    }
  }

  void _clearFields() {
    setState(() {
      _selectedYear = '1';
      _selectedRole;
      _selectedDepartment = '';
    });
  }

  void _saveUser() async {
    String userId = uuid.v4();
    late User newUser;

    if (_selectedRole == "Student") {
      newUser = User(
        id: userId,
        name: '',
        email: '',
        password: '',
        role: _selectedRole!,
        departmentId: _selectedDepartment,
        takenCourses: [],
        enrolledCourses: [],
      );
    } else if (_selectedRole == "Teaching Assistant" ||
        _selectedRole == "Doctor") {
      newUser = User(
        id: userId,
        name: '',
        email: '',
        password: '',
        role: _selectedRole!,
        departmentId: _selectedDepartment,
        enrolledCourses: [],
      );
    }
  }

  Future<void> _handleGoogleSignUp(BuildContext context) async {
    AuthService().googleSignUp(
        role: _selectedRole,
        department: _selectedDepartment,
        year: _selectedYear);
    Navigator.pushNamed(context, '/login');
  }

  Widget getDepartmentDropdown() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _departmentService.getAllDepartments(),
      builder: (context, snapshot) {
        List<DropdownMenuItem> depItems = [];
        if (!snapshot.hasData) {
          const CircularProgressIndicator();
        } else {
          final items = snapshot.data!;
          for (var item in items!) {
            depItems.add(
              DropdownMenuItem(
                value: item['id'],
                child: Text(
                  item['name'],
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
        }
        return DropdownButtonFormField(
            validator: (value) {
              if (value == null) {
                return "please select a Department";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(),
            ),
            items: depItems,
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value!;
              });
            });
      },
    );
  }

  Widget getYearDropDown() {
    return DropdownButtonFormField<String>(
      value: _selectedYear,
      items: years.map((year) {
        return DropdownMenuItem(
          value: year,
          child: Text(
            year,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedYear = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Education Year',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget getRoleDropDown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      items: roles.map((role) {
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
          _selectedRole = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// initialization is here:
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up By Google",
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  getRoleDropDown(),
                  SizedBox(height: 16),
                  if (_selectedRole == "Doctor" ||
                      _selectedRole == "Teaching Assistant") ...[
                    getDepartmentDropdown(),
                    SizedBox(height: 16),
                  ],
                  if (_selectedRole == "Student") ...[
                    getDepartmentDropdown(),
                    SizedBox(height: 16),
                    getYearDropDown(),
                  ],
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Ensures the button wraps its content
                        children: [
                          Image.network(
                            'http://pngimg.com/uploads/google/google_PNG19635.png',
                            height: 24, // Adjust image size
                            width: 24,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Sign Up By Google",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      onPressed: () {
                        _submit(context);
                      },
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
