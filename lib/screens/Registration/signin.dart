import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mobileprogramming/screens/doctorScreens/doctor_dashboard.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/models/user.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                // Welcome Text
                Text(
                  "Welcome Back!",
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter you E-mail.";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "Please enter a valid E-mail.";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passwordController,
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
                ),
                SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 20),
                  ),
                  onPressed: () => _handleLogin(context),
                ),

                // Sign-up Navigation
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Login Handler
  Future<void> _handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your E-mail.")),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter your password.")),
      );
      return;
    }

    try {
      firebase_auth.User? firebaseUser = await AuthService().login(email, password);

      if (firebaseUser != null) {
        // Fetch user details (e.g., role) from your custom User model
        // var userModel = await AuthService().getUserDetails(firebaseUser.uid);
        User? userModel = await User.getUserDetails(firebaseUser.uid);

        // Check if the widget is still in the tree before using context
        if (!context.mounted) return;

        if (userModel != null) {

          if (userModel.role == 'doctor' || userModel.role == 'ta') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDashboard(doctor: userModel),
              ),
            );
          }
          else if (userModel.role == 'admin') {
            Navigator.pushNamed(context, '/admin_home');
          } else {
            Navigator.pushNamed(context, '/user_home');
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => UserHome(/*user: userModel*/),
            //   ),
            // );
          }
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Check if the widget is still in the tree before using context
      if (!context.mounted) return;
      _showError(context, e.message ?? "Login failed. Please try again.");
    } catch (e) {
      // Check if the widget is still in the tree before using context
      if (!context.mounted) return;
      _showError(context, "An unexpected error occurred: $e");
    }
  }

  // Error Display Helper
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
