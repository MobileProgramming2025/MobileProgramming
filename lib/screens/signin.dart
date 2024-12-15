import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/widgets/Signin/customTextField.dart';
import 'package:mobileprogramming/widgets/Signin/custom_button.dart';


class LoginScreen extends StatelessWidget {
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
                _buildWelcomeText(),

                SizedBox(height: 20),

                // Email Field
                CustomTextField(
                  labelText: "Email",
                  controller: emailController,
                 
                ),

                SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  labelText: "Password",
                  controller: passwordController,
                  isPassword: true,
                ),

                SizedBox(height: 30),

                // Login Button
                CustomButton(
                  text: "Login",
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

  // Helper Widget for Welcome Text
  Widget _buildWelcomeText() {
    return Text(
      "Welcome Back!",
      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  // Login Handler
  Future<void> _handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!_validateFields(context, email, password)) return;

    try {
      User? user = await AuthService().login(email, password);

      if (user != null) {
        // Fetch user data (role)
        var userModel = await AuthService().getUserDetails(user.uid);
        if (userModel != null && userModel.role == 'admin') {
          // Navigate to admin screen
          Navigator.pushReplacementNamed(context, '/admin_home');
        } else {
          // Navigate to user screen
          Navigator.pushReplacementNamed(context, '/user_home');
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(context, e.message ?? "Login failed. Please try again.");
    } catch (e) {
      _showError(context, "An unexpected error occurred: $e");
    }
  }

  // Field Validation
  bool _validateFields(BuildContext context, String email, String password) {
    if (email.isEmpty) {
      _showError(context, "Please enter your email.");
      return false;
    }
    if (password.isEmpty) {
      _showError(context, "Please enter your password.");
      return false;
    }
    return true;
  }

  // Error Display Helper
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
