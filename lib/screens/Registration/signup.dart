// signup_screen.dart
import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/widgets/Signin/customTextField.dart';
import 'package:mobileprogramming/widgets/Signin/custom_button.dart';

class SignUpScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final roleController = TextEditingController(); 

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
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
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
                SizedBox(height: 16),
                CustomTextField(
                  labelText: "Role (admin/user)",
                  controller: roleController,
                ),
                SizedBox(height: 30),
                CustomButton(
                  text: "Sign Up",
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    final role = roleController.text.trim();

                    try {
                      await AuthService().signUp(email, password, role);
                      Navigator.pushReplacementNamed(context, '/signin'); // Fixed
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sign-Up Failed: $e")));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
