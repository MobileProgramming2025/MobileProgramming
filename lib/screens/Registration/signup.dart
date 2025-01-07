import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // String? _selectedRole;
  String? _selectedDepartment;

  // final List<String> _roles = [
  //   'Student',
  //   'Doctor',
  //   'Teaching Assistant',
  //   'Admin',
  // ];

  AuthService service = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create an Account",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  controller: nameController,
                ),
                SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  controller: emailController,
                ),
                SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  controller: passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 16),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                        .collection('Departments')
                        .snapshots(),
                  builder: (context, snapshot) {
                    List<DropdownMenuItem<String>> departmentItems = [];
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    else {
                      final items = snapshot.data?.docs.toList();
                      for (var item in items!) {
                        departmentItems.add(
                          DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              item['name'],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        );
                      }
                    }
                    return DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      items: departmentItems,
                      onChanged: (value) {
                        _selectedDepartment = value!;
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select a department";
                        }
                        return null;
                      },
                    );
                  },
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    final department = _selectedDepartment ?? "Unknown";

                    const role = "Student";
 
                    try {
                      await AuthService()
                          .signUp2(name, email, password, role, department);
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/user_home');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Sign-Up Failed: $e"),
                          ),
                        );
                      }
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: Text("Already have an account? Log in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
