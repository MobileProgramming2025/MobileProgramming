import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/screens/UserScreens/user_home.dart';
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

  final Uuid _uuid = Uuid();

  String? _selectedDepartment;

  AuthService service = AuthService();

  String? _validateName(String name) {
    if (name.isEmpty) {
      return "Name cannot be empty";
    }
    return null;
  }

  String? _validateEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (email.isEmpty) {
      return "Email cannot be empty";
    } else if (!emailRegex.hasMatch(email)) {
      return "Enter a valid E-mail address";
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  String? _validateDepartment(String? department) {
    if (department == null) {
      return "Please select a department";
    }
    return null;
  }

  void _handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final department = _selectedDepartment;
    final nameError = _validateName(name);
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    final departmentError = _validateDepartment(department);

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        departmentError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            [nameError, emailError, passwordError, departmentError]
                .where((error) => error != null)
                .join("\n"),
          ),
        ),
      ); 
      return;
    }

    try {
      const role = "Student";
      String userId = _uuid.v4();

      // Create the user in the backend or Firebase
      await service.signUp2(name, email, password, role, department!);

      // Create a User object
      final newUser = User(
        id: userId,
        name: name,
        email: email,
        password: password,
        role: role,
        departmentId: department,
        addedDate: DateTime.now(),
        enrolledCourses: [], 
      );

      if (!mounted) return;

      // Navigate to UserHome, passing the User object
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserHome(user: newUser),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign-Up Failed: $e"),
        ),
      );
    }
  }

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
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Departments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                          "Error loading departments: ${snapshot.error}");
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No departments available");
                    }

                    final items = snapshot.data!.docs;
                    List<DropdownMenuItem<String>> departmentItems =
                        items.map((item) {
                      return DropdownMenuItem(
                        value: item.id,
                        child: Text(
                          item['name'] ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList();

                    return DropdownButtonFormField(
                      decoration: const InputDecoration(
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleSignUp,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
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
                    Navigator.pushNamed(context, '/google_sign_up');
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: const Text("Already have an account? Log in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
