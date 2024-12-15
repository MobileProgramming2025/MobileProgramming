import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../widgets/Signin/custom_button.dart';
import '../widgets/Signin/customTextField.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                  "Welcome Back!",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                CustomTextField(
                  labelText: "Email",
                  controller: emailController,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  labelText: "Password",
                  controller: passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 30),
                CustomButton(
                  text: "Login",
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    try {
                      User? user = await AuthService().login(email, password);
                      if (user != null) {
                        // Fetch user data (role)
                        var userModel =
                            await AuthService().getUserDetails(user.uid);
                        if (userModel != null && userModel.role == 'admin') {
                          // Navigate to admin screen
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          // Navigate to user screen
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login Failed: $e")));
                    }
                  },
                ),
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
}
